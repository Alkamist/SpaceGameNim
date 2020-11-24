import gameinputs
export gameinputs
import gameengine/collisionBody2d


type
  GameState* = object
    controls*: GameControls
    colliders*: seq[CollisionBody2d]

proc initGameState*(): GameState =
  result.colliders.add(initCollisionBody2d())
  result.colliders.add(initCollisionBody2d())
  for i in 0..<result.colliders.len:
    result.colliders[i].updateWorldPolygon()

proc updateColliders(state: var GameState) =
  let numColliders = state.colliders.len

  for i in 0..<numColliders:
    state.colliders[i].isOverlapped = false

  for i in 0..<numColliders:
    for j in i + 1..<numColliders:
      let overlapOccurs = state.colliders[i].overlaps(state.colliders[j])
      state.colliders[i].isOverlapped = state.colliders[i].isOverlapped or overlapOccurs
      state.colliders[j].isOverlapped = state.colliders[j].isOverlapped or overlapOccurs

proc update*(state: var GameState, inputs: GameInputs, delta: float32) =
  state.controls.update()
  state.controls.applyInputs(inputs)

  state.colliders[0].position.x += 3.0 * state.controls.xAxis.value * delta
  state.colliders[0].position.y += 3.0 * state.controls.yAxis.value * delta
  state.colliders[0].rotation += delta
  state.colliders[0].updateWorldPolygon()

  state.updateColliders()