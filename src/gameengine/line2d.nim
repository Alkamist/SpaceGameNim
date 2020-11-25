import options

import ./vector2d
export vector2d


type
  Line2d* = object
    slope*: float32
    yIntercept*: float32

func initLine2d*(slope = 0'f32, yIntercept = 0'f32): Line2d =
  result.slope = slope
  result.yIntercept = yIntercept

func intersects*(line: Line2d, otherLine: Line2d): bool =
  line.slope != otherLine.slope

func intersection*(line: Line2d, otherLine: Line2d): Option[Vector2d] =
  if line.intersects(otherLine):
    let
      numerator = otherLine.yIntercept - line.yIntercept
      denominator = line.slope - otherLine.slope
      x = numerator / denominator
      y = line.slope * x + line.yIntercept

    return some(initVector2d(x, y))


#proc testLine2d =
#  var
#    line = initLine2d(1.0, 0.0)
#    otherLine = initLine2d(-1.0, 1.0)
#
#  echo line.intersection(otherLine)
#
#
#when isMainModule:
#  testLine2d()