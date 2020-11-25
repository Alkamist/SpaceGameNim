import math
import options

import ./vector2d
export vector2d
import ./line2d
export line2d
#import ./linesegment2d
#export linesegment2d


type
  Ray2d* = object
    position*: Vector2d
    angle*: float32

func initRay2d*(position = initVector2d(0.0, 0.0),
                angle = 0'f32): Ray2d =
  result.position = position
  result.angle = angle

func direction*(ray: Ray2d): Vector2d =
  initVector2d(cos(ray.angle), sin(ray.angle))

func slope*(ray: Ray2d): float32 =
  tan(ray.angle)

func toLine2d(ray: Ray2d): Line2d =
  let
    slope = ray.slope
    yIntercept = ray.position.y - slope * ray.position.x
  initLine2d(slope, yIntercept)

func intersection*(ray: Ray2d, line: Line2d): Option[Vector2d] =
  let
    rayAsLine = toLine2d(ray)
    intersection = rayAsLine.intersection(line)

  if intersection.isSome:
    let intersectionNormal = ray.position - intersection.get()

    if ray.direction.dot(intersectionNormal) < 0.0:
      return intersection

func intersection*(line: Line2d, ray: Ray2d): Option[Vector2d] =
  ray.intersection(line)

func intersects*(ray: Ray2d, line: Line2d): bool =
  return ray.intersection(line).isSome

func intersects*(line: Line2d, ray: Ray2d): bool =
  ray.intersects(line)


proc testRay2d =
  let
    ray = initRay2d(position = initVector2d(0.0, 0.0),
                    angle = 0.25 * PI)
    line = initLine2d(-1.0, 1.0)
  echo line.intersects(ray)


when isMainModule:
  testRay2d()