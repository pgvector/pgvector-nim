import pgvector/sparsevec
import std/[strutils, tables]
import unittest

test "toSparseVector array":
  let vec = [1.0, 0, 2, 0, 3, 0].toSparseVector
  check(vec.elements == {0: 1.0f32, 2: 2.0, 4: 3.0}.toTable)
  check(vec.dim == 6)

test "toSparseVector seq":
  let vec = @[1.0, 0, 2, 0, 3, 0].toSparseVector
  check(vec.elements == {0: 1.0f32, 2: 2.0, 4: 3.0}.toTable)
  check(vec.dim == 6)

test "toSparseVector table":
  let vec = {0: 1.0, 2: 2.0, 4: 3.0}.toTable.toSparseVector(6)
  check(vec.elements == {0: 1.0f32, 2: 2.0, 4: 3.0}.toTable)
  check(vec.dim == 6)

test "toSparseVector string":
  let vec = "{1:1.0,3:2.0,5:3.0}/6".toSparseVector
  check(vec.elements == {0: 1.0f32, 2: 2.0, 4: 3.0}.toTable)
  check(vec.dim == 6)

test "$":
  let vec = {0: 1.0, 2: 2.0, 4: 3.0}.toTable.toSparseVector(6)
  check("1:1.0" in $vec)
  check("3:2.0" in $vec)
  check("5:3.0" in $vec)
  check("/6" in $vec)

test "equality":
  let a = @[1.0, 2.0, 3.0].toSparseVector
  let b = @[1.0, 2.0, 3.0].toSparseVector
  let c = @[1.0, 2.0, 3.0, 0.0].toSparseVector
  check(a == b)
  check(a != c)
  check(b != c)
