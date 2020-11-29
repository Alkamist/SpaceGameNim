import math
import std/times
import gameinputs
export gameinputs
import gameengine/math2d


type
  GameState* = object
    time: Duration
    controls*: GameControls
    player*: CollisionBody2d
    staticColliders*: array[0..1, CollisionBody2d]

proc initGameState*(): GameState =
  result.time = initDuration()
  result.player = initCollisionBody2d(position = initVector2d(0.0, 1.5))
  result.staticColliders = [
    initCollisionBody2d(position = initVector2d(-1.0, 0.0)),
    initCollisionBody2d(position = initVector2d(1.0, 0.0)),
  ]
  for i in 0..<result.staticColliders.len:
    result.staticColliders[i].updateWorldPolygon()

proc update*(state: var GameState, inputs: GameInputs, delta: float32) =
  state.time += initDuration(nanoseconds = int64(delta * 1.0e9))

  state.controls.update()
  state.controls.applyInputs(inputs)

  state.player.position.x += 3.0 * state.controls.xAxis.value * delta
  state.player.position.y += 3.0 * state.controls.yAxis.value * delta
  state.player.rotation += delta
  state.player.scale = 0.6 + sin(state.time.inNanoseconds.float64 * 2.0 / 1.0e9) * 0.5
  state.player.updateWorldPolygon()

  for i in 0..3:
    state.player.resolveStaticCollisions(state.staticColliders)