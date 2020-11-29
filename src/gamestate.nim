import gameinputs
export gameinputs
import gameengine/math2d


type
  GameState* = object
    controls*: GameControls
    colliders*: seq[CollisionBody2d]

func initGameState*(): GameState =
  result.colliders.add(initCollisionBody2d(scale = 0.6))
  result.colliders.add(initCollisionBody2d(position = initVector2d(-1.0, 0.0)))
  result.colliders.add(initCollisionBody2d(position = initVector2d(1.0, 0.0)))
  for i in 0..<result.colliders.len:
    result.colliders[i].updateWorldPolygon()

proc update*(state: var GameState, inputs: GameInputs, delta: float32) =
  state.controls.update()
  state.controls.applyInputs(inputs)

  state.colliders[0].position.x += 3.0 * state.controls.xAxis.value * delta
  state.colliders[0].position.y += 3.0 * state.controls.yAxis.value * delta
  state.colliders[0].rotation += delta
  state.colliders[0].updateWorldPolygon()

  state.colliders.updateOverlaps()