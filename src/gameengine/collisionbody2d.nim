import math

import ./linesegment2d
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

func overlapTest(body: CollisionBody2d, other: CollisionBody2d): bool {.inline.} =
  let
    bodySides = body.numberOfSides
    otherSides = other.numberOfSides

  for i in 0..<bodySides:
    let diagonalLine = initLineSegment2d(body.position, body.worldPolygon[i])

    for j in 0..<otherSides:
      let
        edgePointA = other.worldPolygon[j]
        edgePointB = other.worldPolygon[(j + 1) mod otherSides]
        edgeLine = initLineSegment2d(edgePointA, edgePointB)

      if diagonalLine.intersects(edgeLine):
        return true

  false

func overlaps*(body: CollisionBody2d, other: CollisionBody2d): bool =
  if body.overlapTest(other): return true
  if other.overlapTest(body): return true
  false