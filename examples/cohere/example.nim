import db_connector/db_postgres
import std/[envvars, httpclient, json, sequtils, sugar]

let db = db_postgres.open("localhost", "", "", "pgvector_example")

db.exec(sql"CREATE EXTENSION IF NOT EXISTS vector")
db.exec(sql"DROP TABLE IF EXISTS documents")
db.exec(sql"CREATE TABLE documents (id bigserial PRIMARY KEY, content text, embedding vector(1024))")

proc embed(texts: openArray[string], inputType: string): seq[seq[float]] =
  let url = "https://api.cohere.com/v1/embed"
  let body = %*{
    "texts": texts,
    "model": "embed-english-v3.0",
    "input_type": inputType,
    "embedding_types": ["float"]
  }

  let client = newHttpClient()
  client.headers = newHttpHeaders({
    "Authorization": "Bearer " & getenv("CO_API_KEY"),
    "Content-Type": "application/json"
  })

  try:
    let response = client.request(url, httpMethod = HttpPost, body = $body)
    let data = parseJson(response.bodyStream)["embeddings"]["float"]
    collect(newSeqOfCap(data.len)):
      for obj in data:
        collect(newSeqOfCap(obj.len)):
          for v in obj: v.getFloat()
  finally:
    client.close()

let input = [
  "The dog is barking",
  "The cat is purring",
  "The bear is growling"
]
let embeddings = embed(input, "search_document")
for (content, embedding) in zip(input, embeddings):
  db.exec(sql"INSERT INTO documents (content, embedding) VALUES (?, ?)", content, %* embedding)

let query = "forest"
let queryEmbedding = embed([query], "search_query")[0]
let rows = db.getAllRows(sql"SELECT content FROM documents ORDER BY embedding <=> ? LIMIT 5", %* queryEmbedding)
for row in rows:
  echo row[0]

db.close()
