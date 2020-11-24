import math

import ./vector2d
export vector2d

import ./polygon2d
export polygon2d


type
  CollisionBody2d* = object
    localPolygon*: Polygon2d
    worldPolygon*: Polygon2d
    position*: Vector2d
    rotation*: float32
    scale*: float32
    isOverlapped*: bool

func numberOfSides*(body: CollisionBody2d): int {.inline.} =
  body.localPolygon.numberOfSides

proc updateWorldPolygon*(body: var CollisionBody2d,
                         origin = initVector2d(0.0, 0.0),
                         originScale = 1'f32) =
  let numSides = body.numberOfSides
  for i in 0..<numSides:
    let
      localPoint = body.localPolygon[i]
      cosRot = cos(body.rotation)
      sinRot = sin(body.rotation)
      x = (body.scale / originScale) * (localPoint.x * cosRot - localPoint.y * sinRot) +
        (body.position.x - origin.x)
      y = (body.scale / originScale) * (localPoint.x * sinRot + localPoint.y * cosRot) +
        (body.position.y - origin.y)
    body.worldPolygon[i] = initVector2d(x, y)

func initCollisionBody2d*(localPolygon = pentagon(),
                          position = initVector2d(0.0, 0.0),
                          rotation = 0'f32,
                          scale = 1'f32,
                          isOverlapped = false): CollisionBody2d =
  result.localPolygon = localPolygon
  result.worldPolygon = localPolygon
  result.position = position
  result.rotation = rotation
  result.scale = scale
  result.isOverlapped = isOverlapped
  result.updateWorldPolygon()


#proc overlapTest(body: CollisionPolygon, other: CollisionPolygon): bool {.inline.} =
#  let numSides = body.numberOfSides
#
#  if numSides > 2:
#    for pointIndex in 0..<numSides:
#      let
#        pointA = body.worldPoints[pointIndex]
#        pointB = body.worldPoints[(pointIndex + 1) mod numSides]
#        projectionAxis = Vec2(
#          x: pointA.y - pointB.y,
#          y: pointB.x - pointA.x,
#        ).normalize
#
#      let (minimumA, maximumA) = body.axisExtremes(projectionAxis)
#      let (minimumB, maximumB) = other.axisExtremes(projectionAxis)
#
#      if not (maximumB >= minimumA and maximumA >= minimumB):
#        return false
#
#  true
#
#proc overlaps*(body: CollisionPolygon, other: CollisionPolygon): bool =
#  if not body.overlapTest(other): return false
#  if not other.overlapTest(body): return false
#  true
#
#type
#  CollisionGroup* = object
#    colliders*: seq[CollisionPolygon]
#
#proc update*(body: var CollisionGroup) =
#  let numColliders = body.colliders.len
#
#  for i in 0..<numColliders:
#    body.colliders[i].isOverlapped = false
#
#  for i in 0..<numColliders:
#    for j in i + 1..<numColliders:
#      let overlapOccurs = body.colliders[i].overlaps(body.colliders[j])
#      body.colliders[i].isOverlapped = body.colliders[i].isOverlapped or overlapOccurs
#      body.colliders[j].isOverlapped = body.colliders[j].isOverlapped or overlapOccurs