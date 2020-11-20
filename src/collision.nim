import math
import vmath

type
  CollisionPolygon* = object
    points*: seq[Vec2]
    worldPoints*: seq[Vec2]
    position*: Vec2
    rotation*: float32
    isOverlapped*: bool

  CollisionGroup* = object
    colliders*: seq[CollisionPolygon]

func pentagon*(): CollisionPolygon =
  let theta = PI * 2.0 / 5.0
  for i in 0..<5:
    let point = Vec2(
      x: cos(theta * i.float32),
      y: sin(theta * i.float32),
    )
    result.points.add(point)
    result.worldPoints.add(point)

func numberOfSides*(self: CollisionPolygon): int {.inline.} =
  self.worldPoints.len

proc updateWorldPoints*(self: var CollisionPolygon) =
  let numPoints = self.numberOfSides
  for i in 0..<numPoints:
    let modelPoint = self.points[i]
    let cosRot = cos(self.rotation)
    let sinRot = sin(self.rotation)
    self.worldPoints[i] = Vec2(
      x: modelPoint.x * cosRot - modelPoint.y * sinRot + self.position.x,
      y: modelPoint.x * sinRot + modelPoint.y * cosRot + self.position.y,
    )

func axisExtremes(self: CollisionPolygon, axis: Vec2): (float32, float32) {.inline.} =
  var
    minimum = Inf
    maximum = NegInf
  for point in self.worldPoints:
    let axisDot = point.dot(axis)
    minimum = min(minimum, axisDot)
    maximum = max(maximum, axisDot)
  (minimum.float32, maximum.float32)

func overlapTest(self: CollisionPolygon, other: CollisionPolygon): bool {.inline.} =
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

func overlaps*(self: CollisionPolygon, other: CollisionPolygon): bool =
  if not self.overlapTest(other): return false
  if not other.overlapTest(self): return false
  true






#func overlaps*(self: CollisionPolygon, other: CollisionPolygon): bool =
#  let numPoints = self.worldPoints.len
#  if numPoints > 2:
#    for i in 0..<numPoints:
#      let
#        pointA = polygon.worldPoints[i]
#        pointB = polygon.worldPoints[(i + 1) mod numPoints]
#        axisProjection = Vec2(
#          x: pointA.y - pointB.y,
#          y: pointB.x - pointA.x,
#        )
