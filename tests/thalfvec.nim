import pgvector/halfvec
import unittest

test "toHalfVector array":
  let vec = [1.0, 2.0, 3.0].toHalfVector
  check(vec.toSeq == @[1.0f32, 2.0, 3.0])

test "toHalfVector seq":
  let vec = @[1.0, 2.0, 3.0].toHalfVector
  check(vec.toSeq == @[1.0f32, 2.0, 3.0])

test "toHalfVector string":
  let vec = "[1,2,3]".toHalfVector
  check(vec.toSeq == @[1.0f32, 2.0, 3.0])

test "$":
  let vec = @[1.0, 2.0, 3.0].toHalfVector
  check($vec == "[1.0,2.0,3.0]")

test "equality":
  let a = @[1.0, 2.0, 3.0].toHalfVector
  let b = @[1.0, 2.0, 3.0].toHalfVector
  let c = @[1.0, 2.0, 4.0].toHalfVector
  check(a == b)
  check(a != c)
  check(b != c)
