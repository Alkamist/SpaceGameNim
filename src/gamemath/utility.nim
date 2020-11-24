import math


func fixAngle*(angle: float32): float32 =
  var angle = angle
  while angle > PI:
    angle -= PI*2
  while angle < -PI:
    angle += PI*2
  angle