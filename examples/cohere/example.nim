import db_connector/db_postgres
import std/[envvars, httpclient, json, sequtils, strformat, strutils, sugar]

let db = db_postgres.open("localhost", "", "", "pgvector_example")

db.exec(sql"CREATE EXTENSION IF NOT EXISTS vector")
db.exec(sql"DROP TABLE IF EXISTS documents")
db.exec(sql"CREATE TABLE documents (id bigserial PRIMARY KEY, content text, embedding bit(1536))")

proc embed(texts: openArray[string], inputType: string): seq[string] =
  let url = "https://api.cohere.com/v2/embed"
  let body = %*{
    "texts": texts,
    "model": "embed-v4.0",
    "input_type": inputType,
    "embedding_types": ["ubinary"]
  }

  let client = newHttpClient()
  client.headers = newHttpHeaders({
    "Authorization": "Bearer " & getenv("CO_API_KEY"),
    "Content-Type": "application/json"
  })

  try:
    let response = client.request(url, httpMethod = HttpPost, body = $body)
    let data = parseJson(response.bodyStream)["embeddings"]["ubinary"]
    collect(newSeqOfCap(data.len)):
      for obj in data:
        let c = collect(newSeqOfCap(obj.len)):
          for v in obj:
            let u = uint8(v.getInt())
            fmt"{u:08b}"
        c.join
  finally:
    client.close()

let input = [
  "The dog is barking",
  "The cat is purring",
  "The bear is growling"
]
let embeddings = embed(input, "search_document")
for (content, embedding) in zip(input, embeddings):
  db.exec(sql"INSERT INTO documents (content, embedding) VALUES (?, ?)", content, embedding)

let query = "forest"
let queryEmbedding = embed([query], "search_query")[0]
let rows = db.getAllRows(sql"SELECT content FROM documents ORDER BY embedding <~> ? LIMIT 5", queryEmbedding)
for row in rows:
  echo row[0]

db.close()
