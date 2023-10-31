import db_connector/db_postgres
import std/json

let db = db_postgres.open("localhost", "", "", "pgvector_nim_test")

db.exec(sql"CREATE EXTENSION IF NOT EXISTS vector")
db.exec(sql"DROP TABLE IF EXISTS items")

db.exec(sql"CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3))")

let embedding1 = %* @[1, 1, 1];
let embedding2 = %* @[1, 1, 2];
let embedding3 = %* @[2, 2, 2];
db.exec(sql"INSERT INTO items (embedding) VALUES (?), (?), (?)", embedding1, embedding2, embedding3)

let embedding = %* @[1, 1, 1];
let rows = db.getAllRows(sql"SELECT * FROM items ORDER BY embedding <-> ? LIMIT 5", embedding)
for row in rows:
  echo row[0], ": ", parseJson(row[1])

db.exec(sql"CREATE INDEX ON items USING hnsw (embedding vector_l2_ops)")

db.close()
