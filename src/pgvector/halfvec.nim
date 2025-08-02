import std/[json, sequtils, sugar]

type HalfVector* = object
  vec: seq[float32]

proc `$`*(v: HalfVector): string =
  result = $(%* v.vec)

proc toSeq*(v: HalfVector): seq[float32] =
  result = v.vec

proc toHalfVector*[T](a: openArray[T]): HalfVector =
  result = HalfVector(vec: a.toSeq.map(v => float32(v)))

proc toHalfVector*(s: string): HalfVector =
  result = HalfVector(vec: to(parseJson(s), seq[float32]))
