# pgvector-nim

[pgvector](https://github.com/pgvector/pgvector) support for Nim

Supports [db_connector](https://github.com/nim-lang/db_connector)

[![Build Status](https://github.com/pgvector/pgvector-nim/actions/workflows/build.yml/badge.svg)](https://github.com/pgvector/pgvector-nim/actions)

## Getting Started

Run:

```sh
nimble add pgvector
```

And follow the instructions for your database library:

- [db_connector](#db_connector)

Or check out an example:

- [Embeddings](examples/openai/example.nim) with OpenAI
- [Binary embeddings](examples/cohere/example.nim) with Cohere
- [Hybrid search](examples/hybrid/example.nim) with Ollama (Reciprocal Rank Fusion)
- [Sparse search](examples/sparse/example.nim) with Text Embeddings Inference

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
import pgvector

let embedding1 = @[1, 1, 1]
let embedding2 = @[1, 1, 2]
let embedding3 = @[2, 2, 2]
db.exec(sql"INSERT INTO items (embedding) VALUES (?), (?), (?)", embedding1.toVector, embedding2.toVector, embedding3.toVector)
```

Get the nearest neighbors

```nim
let embedding = @[1, 1, 1]
let rows = db.getAllRows(sql"SELECT * FROM items ORDER BY embedding <-> ? LIMIT 5", embedding.toVector)
for row in rows:
  echo row
```

Add an approximate index

```nim
db.exec(sql"CREATE INDEX ON items USING hnsw (embedding vector_l2_ops)")
# or
db.exec(sql"CREATE INDEX ON items USING ivfflat (embedding vector_l2_ops) WITH (lists = 100)")
```

Use `vector_ip_ops` for inner product and `vector_cosine_ops` for cosine distance

See a [full example](tests/tdb_connector.nim)

## Reference

### Vectors

Create a vector from a sequence or array

```nim
let vec = @[1.0, 2.0, 3.0].toVector
```

Get a sequence

```nim
let s = vec.toSeq
```

### Half Vectors

Create a half vector from a sequence or array

```nim
let vec = @[1.0, 2.0, 3.0].toHalfVector
```

Get a sequence

```nim
let s = vec.toSeq
```

### Sparse Vectors

Create a sparse vector from a sequence or array

```nim
let vec = @[1.0, 0.0, 2.0, 0.0, 3.0, 0.0].toSparseVector
```

Or a table of non-zero elements

```nim
let elements = {0: 1.0, 2: 2.0, 4: 3.0}.toTable
let vec = elements.toSparseVector(6)
```

Note: Indices start at 0

Get the number of dimensions

```nim
let dim = vec.dim
```

Get the non-zero elements

```nim
let elements = vec.elements
```

## History

View the [changelog](https://github.com/pgvector/pgvector-nim/blob/master/CHANGELOG.md)

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
nimble test
```

Specify the path to libpq if needed:

```sh
nimble test --passL:-Wl,-rpath,/opt/homebrew/opt/libpq/lib
```

To run an example:

```sh
cd examples/openai
createdb pgvector_example
nim c --run --path:../../src example.nim
```

Specify the path to libpq if needed:

```sh
nim c --run --path:../../src --passL:-Wl,-rpath,/opt/homebrew/opt/libpq/lib example.nim
```
