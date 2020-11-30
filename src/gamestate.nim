import math
import options
import std/times
import gameinputs
export gameinputs
import gameengine/math2d


type
  GameState* = object
    time: Duration
    controls*: GameControls
    player*: CollisionBody2d
    collisionLine*: LineSegment2d
    staticColliders*: array[0..1, CollisionBody2d]

proc initGameState*(): GameState =
  result.time = initDuration()
  result.player = initCollisionBody2d(polygon = initPolygon2d(3),
                                      position = initVector2d(0.0, 1.5))
  result.staticColliders = [
    initCollisionBody2d(polygon = initPolygon2d(3),
                        position = initVector2d(-1.0, 0.0),
                        rotation = Degrees(20.0),
                        scale = 1.0),
    initCollisionBody2d(polygon = initPolygon2d(4),
                        position = initVector2d(1.0, 0.0),
                        rotation = Degrees(45.0)),
  ]
  result.collisionLine = initLineSegment2d(0.0, 0.0, 0.0, 0.0)
  for i in 0..<result.staticColliders.len:
    result.staticColliders[i].updateWorldPolygon()

proc update*(state: var GameState, inputs: GameInputs, delta: float32) =
  state.time += initDuration(nanoseconds = int64(delta * 1.0e9))
  state.controls.update()
  state.controls.applyInputs(inputs)

  state.player.position.x += 3.0 * state.controls.xAxis.value * delta
  state.player.position.y += 3.0 * state.controls.yAxis.value * delta
  #state.player.rotation += delta
  #state.player.scale = 0.6 + sin(state.time.inNanoseconds.float64 * 2.0 / 1.0e9) * 0.5
  state.player.updateWorldPolygon()

  #state.collisionLine = initLineSegment2d(0.0, 0.0, 0.0, 0.0)

  for i in 0..3:
    for collider in state.staticColliders:
      let possibleCollision = collision(state.player, collider)
      if possibleCollision.isSome:
        let
          collision = possibleCollision.get()
          #correction = collision.normal * abs(collision.normal.dot(collision.penetration))

        state.collisionLine = initLineSegment2d(collision.position, collision.position + collision.normal)

        #if state.controls.jump.isPressed:
        state.player.position -= collision.penetration
        state.player.updateWorldPolygon()


  #for i in 0..3:
  #  state.player.resolveStaticCollisions(state.staticColliders)