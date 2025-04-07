import db_connector/db_postgres
import std/[httpclient, json, sequtils, sugar]

let db = db_postgres.open("localhost", "", "", "pgvector_example")

db.exec(sql"CREATE EXTENSION IF NOT EXISTS vector")
db.exec(sql"DROP TABLE IF EXISTS documents")
db.exec(sql"CREATE TABLE documents (id bigserial PRIMARY KEY, content text, embedding vector(768))")
db.exec(sql"CREATE INDEX ON documents USING GIN (to_tsvector('english', content))")

proc embed(input: openArray[string], taskType: string): seq[seq[float]] =
  # nomic-embed-text uses a task prefix
  # https://huggingface.co/nomic-ai/nomic-embed-text-v1.5
  let input = collect(newSeqOfCap(input.len)):
    for v in input: taskType & ": " & v

  let url = "http://localhost:11434/api/embed"
  let body = %*{
    "input": input,
    "model": "nomic-embed-text"
  }

  let client = newHttpClient()
  client.headers = newHttpHeaders({
    "Content-Type": "application/json"
  })

  try:
    let response = client.request(url, httpMethod = HttpPost, body = $body)
    let embeddings = parseJson(response.bodyStream)["embeddings"]
    collect(newSeqOfCap(embeddings.len)):
      for embedding in embeddings:
        collect(newSeqOfCap(embedding.len)):
          for v in embedding: v.getFloat()
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

let stmt = sql"""
WITH semantic_search AS (
    SELECT id, RANK () OVER (ORDER BY embedding <=> ?) AS rank
    FROM documents
    ORDER BY embedding <=> ?
    LIMIT 20
),
keyword_search AS (
    SELECT id, RANK () OVER (ORDER BY ts_rank_cd(to_tsvector('english', content), query) DESC)
    FROM documents, plainto_tsquery('english', ?) query
    WHERE to_tsvector('english', content) @@ query
    ORDER BY ts_rank_cd(to_tsvector('english', content), query) DESC
    LIMIT 20
)
SELECT
    COALESCE(semantic_search.id, keyword_search.id) AS id,
    COALESCE(1.0 / (? + semantic_search.rank), 0.0) +
    COALESCE(1.0 / (? + keyword_search.rank), 0.0) AS score
FROM semantic_search
FULL OUTER JOIN keyword_search ON semantic_search.id = keyword_search.id
ORDER BY score DESC
LIMIT 5
"""
let query = "growling bear"
let queryEmbedding = embed([query], "search_query")[0]
let k = 60
let rows = db.getAllRows(stmt, %* queryEmbedding, %* queryEmbedding, query, k, k)
for row in rows:
  echo "document: " & row[0] & ", RRF score: " & row[1]

db.close()
