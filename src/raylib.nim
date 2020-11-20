import raylib/raylib
export raylib

import vmath

{.push inline.}

converter toVector2*(self: Vec2): Vector2 =
  result.x = self.x
  result.y = self.y

converter toVec2*(self: Vector2): Vec2 =
  result.x = self.x
  result.y = self.y

converter toVector3*(self: Vec3): Vector3 =
  result.x = self.x
  result.y = self.y
  result.z = self.z

converter toVec3*(self: Vector3): Vec3 =
  result.x = self.x
  result.y = self.y
  result.z = self.z

{.pop.}