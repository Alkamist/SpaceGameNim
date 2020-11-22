import std/decls

import player
export player

import collision
export collision

type
  GameState* = object
    #player*: Player
    controls*: PlayerControls
    collisionGroup*: CollisionGroup

proc initGameState*(): GameState =
  #result.player = Player()
  result.collisionGroup = CollisionGroup()
  var colliders {.byaddr.} = result.collisionGroup.colliders
  let offset = 1000000.0'f32
  colliders.add(pentagon(position = Vec2(x: offset, y: 0.0), scale = offset))
  colliders.add(pentagon(position = Vec2(x: offset, y: 0.0), scale = offset))
  colliders.add(pentagon(position = Vec2(x: offset - 3.0, y: 0.0), scale = offset))
  for i in 0..<colliders.len:
    colliders[i].updateWorldPoints(Vec2(x: offset, y: 0.0), offset)

proc update*(self: var GameState, inputs: PlayerInputs, delta: float32) =
  self.controls.update()
  self.controls.applyInputs(inputs)

  var shape {.byaddr.} = self.collisionGroup.colliders[0]
  shape.position.x += 3.0 * self.controls.xAxis.value * delta
  shape.position.y += 3.0 * self.controls.yAxis.value * delta
  shape.rotation += delta
  shape.updateWorldPoints(Vec2(x: 1000000.0'f32, y: 0.0), 1000000.0'f32)

  self.collisionGroup.update()