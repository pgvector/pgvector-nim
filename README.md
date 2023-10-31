# pgvector-nim

[pgvector](https://github.com/pgvector/pgvector) examples for Nim

Supports [db_connector](https://github.com/nim-lang/db_connector)

[![Build Status](https://github.com/pgvector/pgvector-nim/actions/workflows/build.yml/badge.svg?branch=master)](https://github.com/pgvector/pgvector-nim/actions)

## Getting Started

Follow the instructions for your database library:

- [db_connector](#db_connector)

## db_connector

Enable the extension

```nim
db.exec(sql"CREATE EXTENSION IF NOT EXISTS vector")
```

Create a table

```nim
db.exec(sql"CREATE TABLE items (id bigserial PRIMARY KEY, embedding vector(3))")
```

Insert vectors

```nim
import std/json

let embedding1 = @[1, 1, 1];
let embedding2 = @[1, 1, 2];
let embedding3 = @[2, 2, 2];
db.exec(sql"INSERT INTO items (embedding) VALUES (?), (?), (?)", %* embedding1, %* embedding2, %* embedding3)
```

Get the nearest neighbors

```nim
let embedding = @[1, 1, 1];
let rows = db.getAllRows(sql"SELECT * FROM items ORDER BY embedding <-> ? LIMIT 5", %* embedding)
for row in rows:
  echo row
```

Add an approximate index

```nim
db.exec(sql"CREATE INDEX ON items USING ivfflat (embedding vector_l2_ops) WITH (lists = 100)")
# or
db.exec(sql"CREATE INDEX ON items USING hnsw (embedding vector_l2_ops)")
```

Use `vector_ip_ops` for inner product and `vector_cosine_ops` for cosine distance

See a [full example](example.nim)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/pgvector/pgvector-nim/issues)
- Fix bugs and [submit pull requests](https://github.com/pgvector/pgvector-nim/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/pgvector/pgvector-nim.git
cd pgvector-nim
createdb pgvector_nim_test
nimble install db_connector
nim c --run example.nim
```

Specify the path to libpq if needed:

```sh
nim c --run --dynlibOverride:pq --passL:"/opt/homebrew/opt/libpq/lib/libpq.dylib" example.nim
```
