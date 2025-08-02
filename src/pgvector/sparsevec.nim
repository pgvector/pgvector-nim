import std/[strutils, sugar, tables]

type SparseVector* = object
  elements*: Table[int, float32]
  dim*: int

proc `$`*(v: SparseVector): string =
  let elements = collect(newSeqOfCap(v.elements.len)):
    for k, v in v.elements: $(k + 1) & ":" & $v
  result = "{" & elements.join(",") & "}/" & $v.dim

proc toSparseVector*[T](a: openArray[T]): SparseVector =
  var elements = initTable[int, float32]()
  for i, v in a:
    let f = float32(v)
    if f != 0:
      elements[i] = f
  result = SparseVector(elements: elements, dim: a.len)

proc toSparseVector*[T](elements: Table[int, T], dim: int): SparseVector =
  var e = initTable[int, float32]()
  for k, v in elements:
    e[k] = float32(v)
  result = SparseVector(elements: e, dim: dim)

proc toSparseVector*(s: string): SparseVector =
  let parts = s.split("}/", maxsplit = 2)
  var elements = initTable[int, float32]()
  for e in parts[0][1..^1].split(","):
    let ep = e.split(":", maxsplit = 2)
    let index = parseInt(ep[0])
    let value = float32(parseFloat(ep[1]))
    elements[index - 1] = value
  let dim = parseInt(parts[1])
  result = SparseVector(elements: elements, dim: dim)
