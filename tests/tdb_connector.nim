import db_connector/db_postgres
import pgvector
import unittest

test "db_connector":
  let db = db_postgres.open("localhost", "", "", "pgvector_nim_test")

  db.exec(sql"CREATE EXTENSION IF NOT EXISTS vector")
  db.exec(sql"DROP TABLE IF EXISTS items")

  db.exec(sql"CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3))")

  let embedding1 = @[1.0, 1.0, 1.0]
  let embedding2 = @[1.0, 1.0, 2.0]
  let embedding3 = @[2.0, 2.0, 2.0]
  db.exec(sql"INSERT INTO items (embedding) VALUES (?), (?), (?)", embedding1.toVector, embedding2.toVector, embedding3.toVector)

  let embedding = @[1.0, 1.0, 1.0]
  let rows = db.getAllRows(sql"SELECT * FROM items ORDER BY embedding <-> ? LIMIT 5", embedding.toVector)
  for row in rows:
    echo row[0], ": ", row[1].toVector

  db.exec(sql"CREATE INDEX ON items USING hnsw (embedding vector_l2_ops)")

  db.close()
