import std/[json, sequtils, sugar]

type Vector* = object
  vec: seq[float32]

proc `$`*(v: Vector): string =
  result = $(%* v.vec)

proc toSeq*(v: Vector): seq[float32] =
  result = v.vec

proc toVector*[T](a: openArray[T]): Vector =
  result = Vector(vec: a.toSeq.map(v => float32(v)))

proc toVector*(s: string): Vector =
  result = Vector(vec: to(parseJson(s), seq[float32]))
