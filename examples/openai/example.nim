import db_connector/db_postgres
import pgvector
import std/[envvars, httpclient, json, sequtils, sugar]

let db = db_postgres.open("localhost", "", "", "pgvector_example")

db.exec(sql"CREATE EXTENSION IF NOT EXISTS vector")
db.exec(sql"DROP TABLE IF EXISTS documents")
db.exec(sql"CREATE TABLE documents (id bigserial PRIMARY KEY, content text, embedding vector(1536))")

proc embed(input: openArray[string]): seq[seq[float]] =
  let url = "https://api.openai.com/v1/embeddings"
  let body = %*{
    "input": input,
    "model": "text-embedding-3-small"
  }

  let client = newHttpClient()
  client.headers = newHttpHeaders({
    "Authorization": "Bearer " & getenv("OPENAI_API_KEY"),
    "Content-Type": "application/json"
  })

  try:
    let response = client.request(url, httpMethod = HttpPost, body = $body)
    let data = parseJson(response.bodyStream)["data"]
    collect(newSeqOfCap(data.len)):
      for obj in data:
        collect(newSeqOfCap(obj["embedding"].len)):
          for v in obj["embedding"]: v.getFloat()
  finally:
    client.close()

let input = [
  "The dog is barking",
  "The cat is purring",
  "The bear is growling"
]
let embeddings = embed(input)
for (content, embedding) in zip(input, embeddings):
  db.exec(sql"INSERT INTO documents (content, embedding) VALUES (?, ?)", content, embedding.toVector)

let query = "forest"
let queryEmbedding = embed([query])[0]
let rows = db.getAllRows(sql"SELECT content FROM documents ORDER BY embedding <=> ? LIMIT 5", queryEmbedding.toVector)
for row in rows:
  echo row[0]

db.close()
