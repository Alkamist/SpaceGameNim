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

func initGameState*(): GameState =
  #result.player = Player()
  result.collisionGroup = CollisionGroup()
  result.collisionGroup.colliders.add(pentagon())
  result.collisionGroup.colliders.add(pentagon())

proc update*(self: var GameState, inputs: PlayerInputs, delta: float32) =
  self.controls.update()
  self.controls.applyInputs(inputs)

  var shape {.byaddr.} = self.collisionGroup.colliders[0]
  shape.position.x += 3.0 * self.controls.xAxis.value * delta
  shape.position.y += 3.0 * self.controls.yAxis.value * delta
  shape.rotation += delta
  shape.updateWorldPoints()

  shape.isOverlapped = shape.overlaps(self.collisionGroup.colliders[1])
  self.collisionGroup.colliders[1].isOverlapped = self.collisionGroup.colliders[1].overlaps(shape)