import math
import vmath
export vmath

type
  CollisionPolygon* = object
    points*: seq[Vec2]
    worldPoints*: seq[Vec2]
    position*: Vec2
    rotation*: float32
    scale*: float32
    isOverlapped*: bool

proc numberOfSides*(self: CollisionPolygon): int {.inline.} =
  self.points.len

proc updateWorldPoints*(self: var CollisionPolygon,
                        origin = Vec2(x: 0.0, y: 0.0),
                        originScale = 1.0'f32) =
  let numPoints = self.numberOfSides
  for i in 0..<numPoints:
    let modelPoint = self.points[i]
    let cosRot = cos(self.rotation)
    let sinRot = sin(self.rotation)
    self.worldPoints[i] = Vec2(
      x: (self.scale / originScale) * (modelPoint.x * cosRot - modelPoint.y * sinRot) + (self.position.x - origin.x),
      y: (self.scale / originScale) * (modelPoint.x * sinRot + modelPoint.y * cosRot) + (self.position.y - origin.y),
    )

proc pentagon*(position = Vec2(x: 0.0, y: 0.0),
               rotation = 0.0'f32,
               scale = 1.0'f32): CollisionPolygon =
  result.position = position
  result.rotation = rotation
  result.scale = scale

  let theta = PI * 2.0 / 5.0
  for i in 0..<5:
    let point = Vec2(
      x: cos(theta * i.float32),
      y: sin(theta * i.float32),
    )
    result.points.add(point)
    result.worldPoints.add(point)

  result.updateWorldPoints(Vec2(x: 0.0, y: 0.0), 1.0)

proc axisExtremes(self: CollisionPolygon, axis: Vec2): (float32, float32) {.inline.} =
  var
    minimum = Inf
    maximum = NegInf
  for point in self.worldPoints:
    let axisDot = point.dot(axis)
    minimum = min(minimum, axisDot)
    maximum = max(maximum, axisDot)
  (minimum.float32, maximum.float32)

proc overlapTest(self: CollisionPolygon, other: CollisionPolygon): bool {.inline.} =
  let numSides = self.numberOfSides

  if numSides > 2:
    for pointIndex in 0..<numSides:
      let
        pointA = self.worldPoints[pointIndex]
        pointB = self.worldPoints[(pointIndex + 1) mod numSides]
        projectionAxis = Vec2(
          x: pointA.y - pointB.y,
          y: pointB.x - pointA.x,
        ).normalize

      let (minimumA, maximumA) = self.axisExtremes(projectionAxis)
      let (minimumB, maximumB) = other.axisExtremes(projectionAxis)

      if not (maximumB >= minimumA and maximumA >= minimumB):
        return false

  true

proc overlaps*(self: CollisionPolygon, other: CollisionPolygon): bool =
  if not self.overlapTest(other): return false
  if not other.overlapTest(self): return false
  true

type
  CollisionGroup* = object
    colliders*: seq[CollisionPolygon]

proc update*(self: var CollisionGroup) =
  let numColliders = self.colliders.len

  for i in 0..<numColliders:
    self.colliders[i].isOverlapped = false

  for i in 0..<numColliders:
    for j in i + 1..<numColliders:
      let overlapOccurs = self.colliders[i].overlaps(self.colliders[j])
      self.colliders[i].isOverlapped = self.colliders[i].isOverlapped or overlapOccurs
      self.colliders[j].isOverlapped = self.colliders[j].isOverlapped or overlapOccurs