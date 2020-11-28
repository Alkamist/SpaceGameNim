import raylib/raylib
export raylib

import gameengine/math2d


converter toVector2*(self: Vector2d): Vector2 {.inline.} =
  result.x = self.x
  result.y = self.y

converter toVec2*(self: Vector2): Vector2d {.inline.} =
  result.x = self.x
  result.y = self.y