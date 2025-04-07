# good resources
# https://opensearch.org/blog/improving-document-retrieval-with-sparse-semantic-encoders/
# https://huggingface.co/opensearch-project/opensearch-neural-sparse-encoding-v1
#
# run with
# text-embeddings-router --model-id opensearch-project/opensearch-neural-sparse-encoding-v1 --pooling splade

import db_connector/db_postgres
import std/[httpclient, json, sequtils, strutils, sugar]

let db = db_postgres.open("localhost", "", "", "pgvector_example")

db.exec(sql"CREATE EXTENSION IF NOT EXISTS vector")
db.exec(sql"DROP TABLE IF EXISTS documents")
db.exec(sql"CREATE TABLE documents (id bigserial PRIMARY KEY, content text, embedding sparsevec(30522))")

proc embed(inputs: openArray[string]): seq[string] =
  let url = "http://localhost:3000/embed_sparse"
  let body = %*{
    "inputs": inputs
  }

  let client = newHttpClient()
  client.headers = newHttpHeaders({
    "Content-Type": "application/json"
  })

  try:
    let response = client.request(url, httpMethod = HttpPost, body = $body)
    let embeddings = parseJson(response.bodyStream)
    collect(newSeqOfCap(embeddings.len)):
      for e in embeddings:
        let elements = collect(newSeqOfCap(e.len)):
          for v in e: $(v["index"].getInt() + 1) & ":" & $v["value"].getFloat()
        "{" & elements.join(",") & "}/30522"
  finally:
    client.close()

let input = [
  "The dog is barking",
  "The cat is purring",
  "The bear is growling"
]
let embeddings = embed(input)
for (content, embedding) in zip(input, embeddings):
  db.exec(sql"INSERT INTO documents (content, embedding) VALUES (?, ?)", content, embedding)

let query = "forest"
let queryEmbedding = embed([query])[0]
let rows = db.getAllRows(sql"SELECT content FROM documents ORDER BY embedding <#> ? LIMIT 5", queryEmbedding)
for row in rows:
  echo row[0]

db.close()
