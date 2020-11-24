import options
import math

import ./vector2d
export vector2d


type
  LineSegment2d* = object
    points*: array[0..1, Vector2d]

func initLineSegment2d*(x0 = 0'f32,
                        y0 = 0'f32,
                        x1 = 0'f32,
                        y1 = 0'f32): LineSegment2d =
  result.points = [
    initVector2d(x0, y0),
    initVector2d(x1, y1)
  ]

func leftPointIndex*(segment: LineSegment2d): int {.inline.} =
  if segment.points[0].x <= segment.points[1].x: 0
  else: 1

func rightPointIndex*(segment: LineSegment2d): int {.inline.} =
  1 - segment.leftPointIndex

template leftPoint*(segment: LineSegment2d): untyped =
  segment.points[segment.leftPointIndex]

template rightPoint*(segment: LineSegment2d): untyped =
  segment.points[segment.rightPointIndex]

func slope*(segment: LineSegment2d): float32 {.inline.} =
  let
    leftPoint = segment.leftPoint
    rightPoint = segment.rightPoint
  (rightPoint.y - leftPoint.y) / (rightPoint.x - leftPoint.x)

func length*(segment: LineSegment2d): float32 {.inline.} =
  let
    pointA = segment.points[0]
    pointB = segment.points[1]
  sqrt(pow(pointB.x - pointA.x, 2.0) + pow(pointB.y - pointA.y, 2.0))

func containsColinearPoint*(segment: LineSegment2d, point: Vector2d): bool {.inline.} =
  point.x <= max(segment.points[0].x, segment.points[1].x) and
  point.x >= min(segment.points[0].x, segment.points[1].x) and
  point.y <= max(segment.points[0].y, segment.points[1].y) and
  point.y >= min(segment.points[0].y, segment.points[1].y)

func intersects*(a: LineSegment2d, b: LineSegment2d): bool =
  let
    orientation0 = orientation(a.points[0], a.points[1], b.points[0])
    orientation1 = orientation(a.points[0], a.points[1], b.points[1])
    orientation2 = orientation(b.points[0], b.points[1], a.points[0])
    orientation3 = orientation(b.points[0], b.points[1], a.points[1])

  if orientation0 != orientation1 and orientation2 != orientation3: true
  elif orientation0 == Colinear and a.containsColinearPoint(b.points[0]): true
  elif orientation1 == Colinear and a.containsColinearPoint(b.points[1]): true
  elif orientation2 == Colinear and b.containsColinearPoint(a.points[0]): true
  elif orientation3 == Colinear and b.containsColinearPoint(a.points[1]): true
  else: false

func intersection*(a: LineSegment2d, b: LineSegment2d): Option[Vector2d] =
  let
    deltaAX = a.points[1].x - a.points[0].x
    deltaAY = a.points[1].y - a.points[0].y
    deltaBX = b.points[1].x - b.points[0].x
    deltaBY = b.points[1].y - b.points[0].y
    deltaABX = a.points[0].x - b.points[0].x
    deltaABY = a.points[0].y - b.points[0].y
    denominator = -deltaBX * deltaAY + deltaAX * deltaBY
    numerator = deltaBX * deltaABY - deltaBY * deltaABX
    t = numerator / denominator

  if classify(t) != fcNan:
    return some(Vector2d(
      x: a.points[0].x + (t * deltaAX),
      y: a.points[0].y + (t * deltaAY),
    ))


proc testLineSegment2d =
  var
    a = initLineSegment2d(0.0, 0.0, 1.0, 1.0)
    b = initLineSegment2d(0.0, 1.0, 1.0, 0.0)
  assert(a.intersection(b) == some(initVector2d(0.5, 0.5)))

  a = initLineSegment2d(0.0, 0.0, 1.0, 1.0)
  b = initLineSegment2d(0.0, 0.0, 1.0, 1.0)
  assert(a.intersection(b) == none(Vector2d))

  a = initLineSegment2d(0.0, 0.0, 1.0, 1.0)
  assert(a.slope == 1.0)

  a = initLineSegment2d(0.0, 0.0, 0.0, 1.0)
  assert(a.length == 1.0)


when isMainModule:
  testLineSegment2d()