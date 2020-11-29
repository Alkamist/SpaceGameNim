import math
import options


type
  Degrees* = distinct float32
  Radians* = distinct float32

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
    center*: Vector2d
    points*: seq[Vector2d]

  CollisionBody2d* = object
    localPolygon*: Polygon2d
    worldPolygon*: Polygon2d
    position*: Vector2d
    rotation*: float32
    scale*: float32


{.push inline.}

# ================== Forward Declarations ==================

proc slope*(segment: LineSegment2d): float32

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

converter toRadians*(degrees: Degrees): Radians =
  Radians(degrees * float32(PI / 180.0))

converter toDegrees*(radians: Radians): Degrees =
  Degrees(radians * float32(180.0 / PI))

proc toAngle*(slope: float32): Radians =
  Radians(arctan(slope))

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

proc `+`*(vectorA, vectorB: Vector2d): Vector2d =
  result.x = vectorA.x + vectorB.x
  result.y = vectorA.y + vectorB.y

proc `-`*(vectorA, vectorB: Vector2d): Vector2d =
  result.x = vectorA.x - vectorB.x
  result.y = vectorA.y - vectorB.y

proc `*`*(vector: Vector2d, value: float32): Vector2d =
  result.x = vector.x * value
  result.y = vector.y * value

proc `*`*(value: float32, vector: Vector2d): Vector2d =
  value * vector

proc `/`*(vector: Vector2d, value: float32): Vector2d =
  result.x = vector.x / value
  result.y = vector.y / value

proc `+=`*(vectorA: var Vector2d, vectorB: Vector2d) =
  vectorA.x += vectorB.x
  vectorA.y += vectorB.y

proc `-=`*(vectorA: var Vector2d, vectorB: Vector2d) =
  vectorA.x -= vectorB.x
  vectorA.y -= vectorB.y

proc `*=`*(vectorA: var Vector2d, vectorB: float32) =
  vectorA.x *= vectorB
  vectorA.y *= vectorB

proc `/=`*(vectorA: var Vector2d, vectorB: float32) =
  vectorA.x /= vectorB
  vectorA.y /= vectorB

proc `-`*(vector: Vector2d): Vector2d =
  result.x = -vector.x
  result.y = -vector.y

proc length*(vector: Vector2d): float32 =
  sqrt(vector.x * vector.x + vector.y * vector.y)

proc `length=`*(vector: var Vector2d, value: float32) =
  vector *= value / vector.length

proc normalized*(vector: Vector2d): Vector2d =
  let length = vector.length
  if length > 0.0:
    vector / length
  else:
    initVector2d(1.0, 0.0)

proc dot*(vectorA, vectorB: Vector2d): float32 =
  vectorA.x * vectorB.x + vectorA.y * vectorB.y

proc lerp*(vectorA, vectorB: Vector2d; value: float32): Vector2d =
  vectorA * (1.0 - value) + vectorB * value

proc `[]`*(vector: Vector2d, i: int): float32 =
  assert(i == 0 or i == 1)
  if i == 0: return vector.x
  elif i == 1: return vector.y

proc `[]=`*(vector: var Vector2d, i: int, value: float32) =
  assert(i == 0 or i == 1)
  if i == 0: vector.x = value
  elif i == 1: vector.y = value

proc angle*(vector: Vector2d): Radians =
  Radians(arctan2(vector.y, vector.x))

proc angleBetween*(vectorA, vectorB: Vector2d): Radians =
  fixAngle(Radians(arctan2(vectorA.y - vectorB.y, vectorA.x - vectorB.x)))

# ================== Line2d ==================

proc initLine2d*(position = initVector2d(0.0, 0.0),
                 angle = Radians(0.0)): Line2d =
  result.position = position
  result.angle = angle

proc initLine2d*(ray: Ray2d): Line2d =
  initLine2d(ray.position, ray.angle)

proc initLine2d*(segment: LineSegment2d): Line2d =
  initLine2d(segment.points[0], toAngle(segment.slope))

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

proc yIntercept*(line: Line2d): float32 =
  line.position.y - line.position.x * line.slope

# ================== Ray2d ==================

proc initRay2d*(position = initVector2d(0.0, 0.0),
                angle = Radians(0.0)): Ray2d =
  result.position = position
  result.angle = angle

proc direction*(ray: Ray2d): Vector2d =
  initVector2d(cos(ray.angle), sin(ray.angle))

proc slope*(ray: Ray2d): float32 =
  tan(ray.angle)

# ================== LineSegment2d ==================

proc initLineSegment2d*(vectorA = initVector2d(0.0, 0.0),
                        vectorB = initVector2d(0.0, 0.0)): LineSegment2d =
  result.points = [vectorA, vectorB]

proc initLineSegment2d*(x0 = 0'f32,
                        y0 = 0'f32,
                        x1 = 0'f32,
                        y1 = 0'f32): LineSegment2d =
  result.points = [
    initVector2d(x0, y0),
    initVector2d(x1, y1)
  ]

proc leftPointIndex*(segment: LineSegment2d): int =
  if segment.points[0].x <= segment.points[1].x: 0
  else: 1

proc rightPointIndex*(segment: LineSegment2d): int=
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

proc length*(segment: LineSegment2d): float32 =
  let
    pointA = segment.points[0]
    pointB = segment.points[1]
  sqrt(pow(pointB.x - pointA.x, 2.0) + pow(pointB.y - pointA.y, 2.0))

# ================== Polygon2d ==================

proc numberOfSides*(polygon: Polygon2d): int =
  polygon.points.len

proc initPolygon2d*(numberOfSides: int): Polygon2d =
  result.points.setLen(numberOfSides)

  let theta = PI * 2.0 / numberOfSides.float32

  for i in 0..<numberOfSides:
    result.points[i] = initVector2d(x = cos(theta * i.float32),
                                    y = sin(theta * i.float32))

  result.center = initVector2d(0.0, 0.0)

proc axisExtremes(polygon: Polygon2d, axis: Vector2d): (float32, float32) =
  var
    minimum = Inf
    maximum = NegInf
  for point in polygon.points:
    let axisDot = dot(point, axis)
    minimum = min(minimum, axisDot)
    maximum = max(maximum, axisDot)
  (minimum.float32, maximum.float32)

template overlapTest(polygonA, polygonB: Polygon2d): untyped =
  let numSides = polygonA.numberOfSides

  for i in 0..<numSides:
    let
      pointA = polygonA.points[i]
      pointB = polygonA.points[(i + 1) mod numSides]
      projectionAxis = initVector2d(pointA.y - pointB.y,
                                    pointB.x - pointA.x).normalized

    let (minimumA, maximumA) = axisExtremes(polygonA, projectionAxis)
    let (minimumB, maximumB) = axisExtremes(polygonB, projectionAxis)

    overlap = min(overlap, min(maximumA, maximumB) - max(minimumA, minimumB))

    if not (maximumB >= minimumA and maximumA >= minimumB):
      return none(Vector2d)

proc overlap*(polygonA, polygonB: Polygon2d): Option[Vector2d] =
  var overlap = Inf

  overlapTest(polygonA, polygonB)
  overlapTest(polygonB, polygonA)

  let
    x = polygonA.center.x - polygonB.center.x
    y = polygonA.center.y - polygonB.center.y

  some(initVector2d(x, y).normalized * overlap)

# ================== CollisionBody2d ==================

proc numberOfSides*(body: CollisionBody2d): int =
  body.localPolygon.numberOfSides

proc updateWorldPolygon*(body: var CollisionBody2d) =
  let numSides = body.numberOfSides
  body.worldPolygon.center = body.position
  for i in 0..<numSides:
    let
      localPoint = body.localPolygon.points[i]
      cosRot = cos(body.rotation)
      sinRot = sin(body.rotation)
      x = body.scale * (localPoint.x * cosRot - localPoint.y * sinRot) + body.position.x
      y = body.scale * (localPoint.x * sinRot + localPoint.y * cosRot) + body.position.y
    body.worldPolygon.points[i] = initVector2d(x, y)

proc initCollisionBody2d*(polygon = initPolygon2d(5),
                          position = initVector2d(0.0, 0.0),
                          rotation = 0'f32,
                          scale = 1'f32): CollisionBody2d =
  result.localPolygon = polygon
  result.worldPolygon = polygon
  result.position = position
  result.rotation = rotation
  result.scale = scale
  result.updateWorldPolygon()

proc overlap*(bodyA, bodyB: CollisionBody2d): Option[Vector2d] =
  overlap(bodyA.worldPolygon, bodyB.worldPolygon)

proc resolveStaticCollisions*(body: var CollisionBody2d, staticColliders: openArray[CollisionBody2d]) =
  for collider in staticColliders:
    let possibleOverlap = overlap(body, collider)
    if possibleOverlap.isSome:
      body.position += possibleOverlap.get()
      body.updateWorldPolygon()

{.pop.}