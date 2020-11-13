import gameengine

type
  Game* = object
    cubePosition*: Vector3

func initGame*: Game =
  result.cubePosition = Vector3(x: 0.0, y: 0.0, z: 0.0)

proc update*(self: var Game, delta: float) =
  if IsKeyDown(KEY_A):
    self.cubePosition.x += 30.0 * delta
  elif IsKeyDown(KEY_D):
    self.cubePosition.x -= 30.0 * delta