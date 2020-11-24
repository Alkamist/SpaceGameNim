#import options


type
  Point2dOrientation* = enum
    Colinear
    Clockwise
    CounterClockwise

  Point2d* = object
    x: float32
    y: float32

proc initPoint2d*(x = 0'f32, y = 0'f32): Point2d =
  result.x = x
  result.y = y

proc orientation*(a: Point2d, b: Point2d, c: Point2d): Point2dOrientation =
  let value = (b.y - a.y) * (c.x - b.x) - (b.x - a.x) * (c.y - b.y)
  if value == 0.0: Point2dOrientation.Colinear
  elif value > 0.0: Point2dOrientation.Clockwise
  else: Point2dOrientation.CounterClockwise


type
  LineSegment2d* = object
    points*: array[0..1, Point2d]

proc initLineSegment2d*(x0 = 0'f32,
                        y0 = 0'f32,
                        x1 = 0'f32,
                        y1 = 0'f32): LineSegment2d =
  result.points = [
    initPoint2d(x0, y0),
    initPoint2d(x1, y1)
  ]

proc leftPointIndex*(segment: LineSegment2d): int {.inline.} =
  if segment.points[0].x <= segment.points[1].x: 0
  else: 1

proc rightPointIndex*(segment: LineSegment2d): int {.inline.} =
  1 - segment.leftPointIndex

template leftPoint*(segment: LineSegment2d): untyped =
  segment.points[segment.leftPointIndex]

template rightPoint*(segment: LineSegment2d): untyped =
  segment.points[segment.rightPointIndex]

proc slope*(segment: LineSegment2d): float32 =
  let
    leftPoint = segment.leftPoint
    rightPoint = segment.rightPoint
  (rightPoint.y - leftPoint.y) / (rightPoint.x - leftPoint.x)

proc containsColinearPoint*(segment: LineSegment2d, point: Point2d): bool =
  point.x <= max(segment.points[0].x, segment.points[1].x) and
  point.x >= min(segment.points[0].x, segment.points[1].x) and
  point.y <= max(segment.points[0].y, segment.points[1].y) and
  point.y >= min(segment.points[0].y, segment.points[1].y)

#proc intersection*(a: LineSegment2d, b: LineSegment2d): Option[Point2d] =
#  let
#    deltaAX = a.points[1].x - a.points[0].x
#    deltaAY = a.points[1].y - a.points[0].y
#    deltaBX = b.points[1].x - b.points[0].x
#    deltaBY = b.points[1].y - b.points[0].y
#    deltaABX = a.points[0].x - b.points[0].x
#    deltaABY = a.points[0].y - b.points[0].y
#
#    denominator = -deltaBX * deltaAY + deltaAX * deltaBY
#
#    sNumerator = -deltaAY * deltaABX + deltaAX * deltaABY
#    s = sNumerator / denominator
#
#    tNumerator = deltaBX * deltaABY - deltaBY * deltaABX
#    t = tNumerator / denominator
#
#  if s >= 0.0 and s <= 1.0 and t >= 0.0 and t <= 1.0:
#    return some(Point2d(
#      x: a.points[0].x + (t * deltaAX),
#      y: a.points[0].y + (t * deltaAY),
#    ))

proc intersects*(a: LineSegment2d, b: LineSegment2d): bool =
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


proc testPoint2dOrientation =
  var
    pointA = initPoint2d(0.0, 0.0)
    pointB = initPoint2d(1.0, 0.0)
    pointC = initPoint2d(0.5, 1.0)
  assert(orientation(pointA, pointB, pointC) == CounterClockwise)

  pointA = initPoint2d(0.0, 0.0)
  pointB = initPoint2d(0.5, 1.0)
  pointC = initPoint2d(1.0, 0.0)
  assert(orientation(pointA, pointB, pointC) == Clockwise)

  pointA = initPoint2d(0.0, 0.0)
  pointB = initPoint2d(1.0, 0.0)
  pointC = initPoint2d(0.5, 0.0)
  assert(orientation(pointA, pointB, pointC) == Colinear)

proc testLineSegment2dIntersection =
  var
    a = initLineSegment2d(0.0, 0.0, 1.0, 1.0)
    b = initLineSegment2d(0.0, 1.0, 1.0, 0.0)
  assert(a.intersects(b))

  a = initLineSegment2d(0.0, 0.0, 1.0, 1.0)
  b = initLineSegment2d(0.0, 0.0, 1.0, 1.0)
  assert(a.intersects(b))

  a = initLineSegment2d(0.0, 0.0, 1.0, 1.0)
  echo a.slope


when isMainModule:
  testPoint2dOrientation()
  testLineSegment2dIntersection()