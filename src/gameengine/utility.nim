import math


#type
#  Degrees* = distinct float32
#  Radians* = distinct float32
#
#converter toRadians*(degrees: Degrees): Radians {.inline.} =
#  Radians(degrees * PI / 180.0)
#
#converter toFloat32*(degrees: Degrees): float32 {.inline.} =
#  float32(degrees)
#
#converter toDegrees*(radians: Radians): Degrees {.inline.} =
#  Degrees(radians *  180.0 / PI)
#
#converter toFloat32*(radians: Radians): float32 {.inline.} =
#  float32(radians)

func fixAngle*(angle: float32): float32 =
  var angle = angle
  while angle > PI:
    angle -= PI * 2
  while angle < -PI:
    angle += PI * 2
  angle