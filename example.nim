import db_connector/db_postgres

let db = db_postgres.open("localhost", "", "", "pgvector_nim_test")

db.exec(sql"CREATE EXTENSION IF NOT EXISTS vector")
db.exec(sql"DROP TABLE IF EXISTS items")

db.exec(sql"CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3))")

db.exec(sql"INSERT INTO items (embedding) VALUES (?), (?), (?)", "[1,1,1]", "[2,2,2]", "[1,1,2]")

let rows = db.getAllRows(sql"SELECT * FROM items ORDER BY embedding <-> ? LIMIT 5", "[1,1,1]")
for row in rows:
  echo row

db.exec(sql"CREATE INDEX ON items USING hnsw (embedding vector_l2_ops)")

db.close()
