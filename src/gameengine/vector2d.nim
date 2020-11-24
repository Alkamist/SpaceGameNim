import math
import strformat

import ./utility


type
  Vector2dOrientation* = enum
    Colinear
    Clockwise
    CounterClockwise

  Vector2d* = object
    x*: float32
    y*: float32

func initVector2d*(x = 0'f32, y = 0'f32): Vector2d {.inline.} =
  result.x = x
  result.y = y

func orientation*(a: Vector2d, b: Vector2d, c: Vector2d): Vector2dOrientation =
  let value = (b.y - a.y) * (c.x - b.x) - (b.x - a.x) * (c.y - b.y)
  if value == 0.0: Colinear
  elif value > 0.0: Clockwise
  else: CounterClockwise

func `+`*(a: Vector2d, b: Vector2d): Vector2d {.inline.} =
  result.x = a.x + b.x
  result.y = a.y + b.y

func `-`*(a: Vector2d, b: Vector2d): Vector2d {.inline.} =
  result.x = a.x - b.x
  result.y = a.y - b.y

func `*`*(a: Vector2d, b: float32): Vector2d {.inline.} =
  result.x = a.x * b
  result.y = a.y * b

func `*`*(a: float32, b: Vector2d): Vector2d {.inline.} =
  b * a

func `/`*(a: Vector2d, b: float32): Vector2d {.inline.} =
  result.x = a.x / b
  result.y = a.y / b

func `+=`*(a: var Vector2d, b: Vector2d) {.inline.} =
  a.x += b.x
  a.y += b.y

func `-=`*(a: var Vector2d, b: Vector2d) {.inline.} =
  a.x -= b.x
  a.y -= b.y

func `*=`*(a: var Vector2d, b: float32) {.inline.} =
  a.x *= b
  a.y *= b

func `/=`*(a: var Vector2d, b: float32) {.inline.} =
  a.x /= b
  a.y /= b

func `-`*(a: Vector2d): Vector2d {.inline.} =
  result.x = -a.x
  result.y = -a.y

func length*(a: Vector2d): float32 {.inline.} =
  sqrt(a.x * a.x + a.y * a.y)

func `length=`*(a: var Vector2d, b: float32) {.inline.} =
  a *= b / a.length

func normalized*(a: Vector2d): Vector2d {.inline.} =
  a / a.length

func dot*(a: Vector2d, b: Vector2d): float32 {.inline.} =
  a.x * b.x + a.y * b.y

func lerp*(a: Vector2d, b: Vector2d, v: float32): Vector2d {.inline.} =
  a * (1.0 - v) + b * v

func `[]`*(a: Vector2d, i: int): float32 {.inline.} =
  assert(i == 0 or i == 1)
  if i == 0: return a.x
  elif i == 1: return a.y

func `[]=`*(a: var Vector2d, i: int, b: float32) {.inline.} =
  assert(i == 0 or i == 1)
  if i == 0: a.x = b
  elif i == 1: a.y = b

func `$`*(a: Vector2d): string {.inline.} =
  &"({a.x:.4f}, {a.y:.4f})"

func angle*(a: Vector2d): float32 {.inline.} =
  arctan2(a.y, a.x)

func angleBetween*(a: Vector2d, b: Vector2d): float32 {.inline.} =
  fixAngle(arctan2(a.y - b.y, a.x - b.x))