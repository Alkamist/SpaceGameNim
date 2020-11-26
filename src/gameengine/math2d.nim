import math
import options


type
  Degrees* = distinct float32
  Radians* = distinct float32

  Intersection2dKind* {.pure.} = enum
    Point
    Line
    Ray
    LineSegment

  Intersection2d* = object
    case kind*: Intersection2dKind
    of Intersection2dKind.Point:
      point*: Vector2d
    of Intersection2dKind.Line:
      line*: Line2d
    of Intersection2dKind.Ray:
      ray*: Ray2d
    of Intersection2dKind.LineSegment:
      segment*: LineSegment2d

  Vector2dOrientation* {.pure.} = enum
    Colinear
    Clockwise
    CounterClockwise

  Vector2d* = object
    x*: float32
    y*: float32

  Line2d* = object
    position*: Vector2d
    angle*: Radians

  Ray2d* = object
    position*: Vector2d
    angle*: Radians

  LineSegment2d* = object
    points*: array[0..1, Vector2d]

  Polygon2d* = object
    points*: seq[Vector2d]

  CollisionBody2d* = object
    localPolygon*: Polygon2d
    worldPolygon*: Polygon2d
    position*: Vector2d
    rotation*: float32
    scale*: float32
    isOverlapped*: bool


{.push inline.}

# ================== Utility ==================

const
  angleRight = Radians(0.0)
  angleUp = Radians(0.5 * PI)
  angleLeft = Radians(PI)
  angleDown = Radians(1.5 * PI)

converter toFloat32*(degrees: var Degrees): var float32 =
  return degrees.float32

converter toFloat32*(degrees: Degrees): float32 =
  degrees.float32

converter toFloat32*(radians: var Radians): var float32 =
  return radians.float32

converter toFloat32*(radians: Radians): float32 =
  radians.float32

converter toRadians(degrees: Degrees): Radians =
  Radians(degrees * float32(PI / 180.0))

converter toDegrees(radians: Radians): Degrees =
  Degrees(radians * float32(180.0 / PI))

proc fixAngle*(angle: Radians): Radians =
  var angle = angle
  while angle > PI:
    angle -= PI * 2.0
  while angle < -PI:
    angle += PI * 2.0
  angle

# ================== Vector2d ==================

proc initVector2d*(x = 0'f32, y = 0'f32): Vector2d =
  result.x = x
  result.y = y

proc orientation*(a, b, c: Vector2d): Vector2dOrientation =
  let value = (b.y - a.y) * (c.x - b.x) - (b.x - a.x) * (c.y - b.y)
  if value == 0.0: Vector2dOrientation.Colinear
  elif value > 0.0: Vector2dOrientation.Clockwise
  else: Vector2dOrientation.CounterClockwise

proc `+`*(a, b: Vector2d): Vector2d =
  result.x = a.x + b.x
  result.y = a.y + b.y

proc `-`*(a, b: Vector2d): Vector2d =
  result.x = a.x - b.x
  result.y = a.y - b.y

proc `*`*(a: Vector2d, b: float32): Vector2d =
  result.x = a.x * b
  result.y = a.y * b

proc `*`*(a: float32, b: Vector2d): Vector2d =
  b * a

proc `/`*(a: Vector2d, b: float32): Vector2d =
  result.x = a.x / b
  result.y = a.y / b

proc `+=`*(a: var Vector2d, b: Vector2d) =
  a.x += b.x
  a.y += b.y

proc `-=`*(a: var Vector2d, b: Vector2d) =
  a.x -= b.x
  a.y -= b.y

proc `*=`*(a: var Vector2d, b: float32) =
  a.x *= b
  a.y *= b

proc `/=`*(a: var Vector2d, b: float32) =
  a.x /= b
  a.y /= b

proc `-`*(a: Vector2d): Vector2d =
  result.x = -a.x
  result.y = -a.y

proc length*(a: Vector2d): float32 =
  sqrt(a.x * a.x + a.y * a.y)

proc `length=`*(a: var Vector2d, b: float32) =
  a *= b / a.length

proc normalized*(a: Vector2d): Vector2d =
  a / a.length

proc dot*(a, b: Vector2d): float32 =
  a.x * b.x + a.y * b.y

proc lerp*(a, b: Vector2d; v: float32): Vector2d =
  a * (1.0 - v) + b * v

proc `[]`*(a: Vector2d, i: int): float32 =
  assert(i == 0 or i == 1)
  if i == 0: return a.x
  elif i == 1: return a.y

proc `[]=`*(a: var Vector2d, i: int, b: float32) =
  assert(i == 0 or i == 1)
  if i == 0: a.x = b
  elif i == 1: a.y = b

proc angle*(a: Vector2d): Radians =
  Radians(arctan2(a.y, a.x))

proc angleBetween*(a, b: Vector2d): Radians =
  fixAngle(Radians(arctan2(a.y - b.y, a.x - b.x)))

# ================== Line2d ==================

proc initLine2d*(position = initVector2d(0.0, 0.0),
                 angle = Radians(0.0)): Line2d =
  result.position = position
  result.angle = angle

proc initLine2d*(ray: Ray2d): Line2d =
  initLine2d(ray.position, ray.angle)

proc slope*(line: Line2d): float32 =
  tan(line.angle)

proc isRight*(line: Line2d): bool =
  line.angle == angleRight

proc isUp*(line: Line2d): bool =
  line.angle == angleUp

proc isLeft*(line: Line2d): bool =
  line.angle == angleLeft

proc isDown*(line: Line2d): bool =
  line.angle == angleDown

proc isVertical*(line: Line2d): bool =
  line.isUp or line.isDown

proc isHorizontal*(line: Line2d): bool =
  line.isLeft or line.isRight

proc intersects*(a, b: Line2d): bool =
  a == b or a.slope != b.slope

proc intersection*(a, b: Line2d): Option[Intersection2d] =
  if a.intersects(b):
    if a == b:
      return some(Intersection2d(
        kind: Intersection2dKind.Line,
        line: a,
      ))

    else:
      var
        x: float32
        y: float32

      if a.isVertical:
        let bYIntercept = b.position.y - b.position.x * b.slope
        x = a.position.x
        y = b.slope * x + bYIntercept

      elif b.isVertical:
        let aYIntercept = a.position.y - a.position.x * a.slope
        x = b.position.x
        y = a.slope * x + aYIntercept

      else:
        let
          aYIntercept = a.position.y - a.position.x * a.slope
          bYIntercept = b.position.y - b.position.x * b.slope
          numerator = bYIntercept - aYIntercept
          denominator = a.slope - b.slope
        x = numerator / denominator
        y = a.slope * x + aYIntercept

      return some(Intersection2d(
        kind: Intersection2dKind.Point,
        point: initVector2d(x, y),
      ))

# ================== Ray2d ==================

proc initRay2d*(position = initVector2d(0.0, 0.0),
                angle = Radians(0.0)): Ray2d =
  result.position = position
  result.angle = angle

proc direction*(ray: Ray2d): Vector2d =
  initVector2d(cos(ray.angle), sin(ray.angle))

proc slope*(ray: Ray2d): float32 =
  tan(ray.angle)

proc intersection*(ray: Ray2d, line: Line2d): Option[Intersection2d] =
  let
    rayAsLine = initLine2d(ray)
    possibleIntersection = rayAsLine.intersection(line)

  if possibleIntersection.isSome:
    let intersection = possibleIntersection.get()

    case intersection.kind:
    of Intersection2dKind.Point:
      let intersectionNormal = ray.position - intersection.point
      if ray.direction.dot(intersectionNormal) < 0.0:
        return possibleIntersection

    of Intersection2dKind.Line:
      return some(Intersection2d(
        kind: Intersection2dKind.Ray,
        ray: ray,
      ))

    else:
      discard

proc intersection*(line: Line2d, ray: Ray2d): Option[Intersection2d] =
  ray.intersection(line)

proc intersects*(ray: Ray2d, line: Line2d): bool =
  ray.intersection(line).isSome

proc intersects*(line: Line2d, ray: Ray2d): bool =
  ray.intersects(line)

# ================== LineSegment2d ==================

# proc initLineSegment2d*(a = initVector2d(0.0, 0.0),
#                         b = initVector2d(0.0, 0.0)): LineSegment2d =
#   result.points = [a, b]

# proc initLineSegment2d*(x0 = 0'f32,
#                         y0 = 0'f32,
#                         x1 = 0'f32,
#                         y1 = 0'f32): LineSegment2d =
#   result.points = [
#     initVector2d(x0, y0),
#     initVector2d(x1, y1)
#   ]

# proc leftPointIndex*(segment: LineSegment2d): int =
#   if segment.points[0].x <= segment.points[1].x: 0
#   else: 1

# proc rightPointIndex*(segment: LineSegment2d): int=
#   1 - segment.leftPointIndex

# template leftPoint*(segment: LineSegment2d): untyped =
#   segment.points[segment.leftPointIndex]

# template rightPoint*(segment: LineSegment2d): untyped =
#   segment.points[segment.rightPointIndex]

# proc slope*(segment: LineSegment2d): float32 =
#   let
#     leftPoint = segment.leftPoint
#     rightPoint = segment.rightPoint
#   (rightPoint.y - leftPoint.y) / (rightPoint.x - leftPoint.x)

# proc length*(segment: LineSegment2d): float32 =
#   let
#     pointA = segment.points[0]
#     pointB = segment.points[1]
#   sqrt(pow(pointB.x - pointA.x, 2.0) + pow(pointB.y - pointA.y, 2.0))

# proc containsColinearPoint*(segment: LineSegment2d, point: Vector2d): bool =
#   point.x <= max(segment.points[0].x, segment.points[1].x) and
#   point.x >= min(segment.points[0].x, segment.points[1].x) and
#   point.y <= max(segment.points[0].y, segment.points[1].y) and
#   point.y >= min(segment.points[0].y, segment.points[1].y)

# proc intersection*(segment: LineSegment2d, line: Line2d): Option[Vector2d] =
#   let
#     segmentAsLine = toLine2d(segment)
#     possibleIntersection = segmentAsLine.intersection(line)

#   if possibleIntersection.isSome:
#     let
#       intersection = possibleIntersection.get()
#       normalA = intersection - segment.points[0]
#       normalB = intersection - segment.points[1]

#     if normalA.dot(normalB) <= 0.0:
#       return possibleIntersection

# proc intersects*(segment: LineSegment2d, line: Line2d): bool =
#   segment.intersection(line).isSome

# proc intersection*(line: Line2d, segment: LineSegment2d): Option[Vector2d] =
#   segment.intersection(line)

# proc intersects*(line: Line2d, segment: LineSegment2d): bool =
#   segment.intersects(line)

# proc intersection*(segment: LineSegment2d, ray: Ray2d): Option[Vector2d] =
#   let
#     segmentAsLine = toLine2d(segment)
#     possibleIntersection = segmentAsLine.intersection(ray)

#   if possibleIntersection.isSome:
#     let
#       intersection = possibleIntersection.get()
#       normalA = intersection - segment.points[0]
#       normalB = intersection - segment.points[1]

#     if normalA.dot(normalB) <= 0.0:
#       return possibleIntersection

# proc intersects*(segment: LineSegment2d, ray: Ray2d): bool =
#   segment.intersection(ray).isSome

# proc intersection*(ray: Ray2d, segment: LineSegment2d): Option[Vector2d] =
#   segment.intersection(ray)

# proc intersects*(ray: Ray2d, segment: LineSegment2d): bool =
#   segment.intersects(ray)

# proc intersects*(a, b: LineSegment2d): bool =
#   let
#     orientation0 = orientation(a.points[0], a.points[1], b.points[0])
#     orientation1 = orientation(a.points[0], a.points[1], b.points[1])
#     orientation2 = orientation(b.points[0], b.points[1], a.points[0])
#     orientation3 = orientation(b.points[0], b.points[1], a.points[1])

#   if orientation0 != orientation1 and orientation2 != orientation3: true
#   elif orientation0 == Vector2dOrientation.Colinear and a.containsColinearPoint(b.points[0]): true
#   elif orientation1 == Vector2dOrientation.Colinear and a.containsColinearPoint(b.points[1]): true
#   elif orientation2 == Vector2dOrientation.Colinear and b.containsColinearPoint(a.points[0]): true
#   elif orientation3 == Vector2dOrientation.Colinear and b.containsColinearPoint(a.points[1]): true
#   else: false

# proc intersection*(a, b: LineSegment2d): Option[Vector2d] =
#   if a.intersects(b):
#     let
#       deltaAX = a.points[1].x - a.points[0].x
#       deltaAY = a.points[1].y - a.points[0].y
#       deltaBX = b.points[1].x - b.points[0].x
#       deltaBY = b.points[1].y - b.points[0].y
#       deltaABX = a.points[0].x - b.points[0].x
#       deltaABY = a.points[0].y - b.points[0].y
#       denominator = -deltaBX * deltaAY + deltaAX * deltaBY
#       numerator = deltaBX * deltaABY - deltaBY * deltaABX
#       t = numerator / denominator

#     return some(Vector2d(
#       x: a.points[0].x + (t * deltaAX),
#       y: a.points[0].y + (t * deltaAY),
#     ))

# ================== Polygon2d ==================

# proc numberOfSides*(polygon: Polygon2d): int =
#   polygon.points.len

# proc pentagon*: Polygon2d =
#   let theta = PI * 2.0 / 5.0
#   for i in 0..<5:
#     let point = initVector2d(x = cos(theta * i.float32),
#                              y = sin(theta * i.float32))
#     result.points.add(point)

# proc `[]`*(polygon: Polygon2d, i: int): Vector2d =
#   polygon.points[i]

# proc `[]=`*(polygon: var Polygon2d, i: int, v: Vector2d) =
#   polygon.points[i] = v

# ================== CollisionBody2d ==================

# proc numberOfSides*(body: CollisionBody2d): int =
#   body.localPolygon.numberOfSides

# proc updateWorldPolygon*(body: var CollisionBody2d,
#                          origin = initVector2d(0.0, 0.0),
#                          originScale = 1'f32) =
#   let numSides = body.numberOfSides
#   for i in 0..<numSides:
#     let
#       localPoint = body.localPolygon[i]
#       cosRot = cos(body.rotation)
#       sinRot = sin(body.rotation)
#       x = (body.scale / originScale) * (localPoint.x * cosRot - localPoint.y * sinRot) +
#         (body.position.x - origin.x)
#       y = (body.scale / originScale) * (localPoint.x * sinRot + localPoint.y * cosRot) +
#         (body.position.y - origin.y)
#     body.worldPolygon[i] = initVector2d(x, y)

# proc initCollisionBody2d*(localPolygon = pentagon(),
#                           position = initVector2d(0.0, 0.0),
#                           rotation = 0'f32,
#                           scale = 1'f32,
#                           isOverlapped = false): CollisionBody2d =
#   result.localPolygon = localPolygon
#   result.worldPolygon = localPolygon
#   result.position = position
#   result.rotation = rotation
#   result.scale = scale
#   result.isOverlapped = isOverlapped
#   result.updateWorldPolygon()

# proc pointIsInside(body: CollisionBody2d, point: Vector2d): bool =
#   let
#     ray = initRay2d(point, 0.0)
#     bodySides = body.numberOfSides

#   var numIntersects = 0
#   for i in 0..<bodySides:
#     let
#       edgePointA = body.worldPolygon[i]
#       edgePointB = body.worldPolygon[(i + 1) mod bodySides]
#       edgeLine = initLineSegment2d(edgePointA, edgePointB)

#     if ray.intersects(edgeLine):
#       numIntersects += 1

#   # The number of intersects is odd.
#   numIntersects mod 2 != 0

# proc overlapTest(body, other: CollisionBody2d): bool =
#   let
#     bodySides = body.numberOfSides
#     otherSides = other.numberOfSides

#   for i in 0..<bodySides:
#     let diagonalLine = initLineSegment2d(body.position, body.worldPolygon[i])

#     for j in 0..<otherSides:
#       let
#         edgePointA = other.worldPolygon[j]
#         edgePointB = other.worldPolygon[(j + 1) mod otherSides]
#         edgeLine = initLineSegment2d(edgePointA, edgePointB)

#       if diagonalLine.intersects(edgeLine):
#         return true

#   false

# proc overlaps*(body, other: CollisionBody2d): bool =
#   if body.pointIsInside(other.position): return true
#   if other.pointIsInside(body.position): return true
#   #if body.overlapTest(other): return true
#   #if other.overlapTest(body): return true
#   false

{.pop.}

# ================== Test ==================

proc printIntersection2d(possibleIntersection: Option[Intersection2d]) =
  if possibleIntersection.isSome:
    let
      intersection = possibleIntersection.get()
      kind = intersection.kind

    case kind:
    of Intersection2dKind.Point:
      echo "Point"
      echo intersection.point
    of Intersection2dKind.Line:
      echo "Line"
      echo intersection.line
    of Intersection2dKind.Ray:
      echo "Ray"
      echo intersection.ray
      echo intersection.ray.angle.toDegrees.float32
    of Intersection2dKind.LineSegment:
      echo "LineSegment"
      echo intersection.segment

  else:
    echo "No Intersection"

when isMainModule:
  let
    a = initRay2d(initVector2d(0.0, 0.0), Degrees(45.0))
    b = initLine2d(initVector2d(0.0, 0.0), Degrees(45.0))

  printIntersection2d(a.intersection(b))