import math

import ./vector2d
export vector2d


type
  Polygon2d* = object
    points*: seq[Vector2d]

func numberOfSides*(polygon: Polygon2d): int {.inline.} =
  polygon.points.len

func pentagon*: Polygon2d =
  let theta = PI * 2.0 / 5.0
  for i in 0..<5:
    let point = initVector2d(x = cos(theta * i.float32),
                             y = sin(theta * i.float32))
    result.points.add(point)

func `[]`*(polygon: Polygon2d, i: int): Vector2d {.inline.} =
  polygon.points[i]

func `[]=`*(polygon: var Polygon2d, i: int, v: Vector2d) {.inline.} =
  polygon.points[i] = v