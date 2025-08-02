import pgvector/vector
import unittest

test "toVector array":
  let vec = [1.0, 2.0, 3.0].toVector
  check(vec.toSeq == @[1.0f32, 2.0, 3.0])

test "toVector seq":
  let vec = @[1.0, 2.0, 3.0].toVector
  check(vec.toSeq == @[1.0f32, 2.0, 3.0])

test "toVector string":
  let vec = "[1,2,3]".toVector
  check(vec.toSeq == @[1.0f32, 2.0, 3.0])

test "$":
  let vec = @[1.0, 2.0, 3.0].toVector
  check($vec == "[1.0,2.0,3.0]")

test "equality":
  let a = @[1.0, 2.0, 3.0].toVector
  let b = @[1.0, 2.0, 3.0].toVector
  let c = @[1.0, 2.0, 4.0].toVector
  check(a == b)
  check(a != c)
  check(b != c)
