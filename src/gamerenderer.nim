import fixedtimestep
import gameengine
import game

type
  GameRenderer* = object
    game*: Game
    previousGameState*: Game
    displayFps*: float32
    physicsFps*: float32
    windowTitle*: cstring
    windowWidth*: int32
    windowHeight*: int32

func initGameRenderer*(
  windowTitle: cstring,
  windowWidth: int32,
  windowHeight: int32,
  displayFps: float32,
  physicsFps: float32): GameRenderer =

  result.game = initGame()
  result.previousGameState = initGame()
  result.displayFps = displayFps
  result.physicsFps = physicsFps
  result.windowTitle = windowTitle
  result.windowWidth = windowWidth
  result.windowHeight = windowHeight

proc render3D(self: var GameRenderer, interpolation: float32) =
  var interpolatedCubePosition = self.previousGameState.cubePosition.lerp(
    self.game.cubePosition,
    interpolation,
  )
  DrawCube(interpolatedCubePosition, 1.0, 1.0, 1.0, RAYWHITE)

proc render2D(self: var GameRenderer, interpolation: float32) =
  DrawFPS(10, 10)

proc run*(self: var GameRenderer) =
  InitWindow(self.windowWidth, self.windowHeight, self.windowTitle)
  SetTargetFPS(self.displayFps.int32)

  var camera = Camera(
    position: Vector3(x: 0.0, y: 15.0, z: 0.0),
    target: Vector3(x: 0.0, y: 0.0, z: 0.0),
    up: Vector3(x: 0.0, y: 0.0, z: 1.0),
    fovy: 45.0,
    typex: CAMERA_PERSPECTIVE,
  )

  SetCameraMode(camera, CAMERA_FIRST_PERSON)

  runGameWhile(not WindowShouldClose(), self.physicsFps):
    update:
      self.previousGameState = self.game
      self.game.update(1.0 / self.physicsFps)

    draw(interpolation):
      BeginDrawing()
      ClearBackground(BLACK)
      BeginMode3D(camera)
      self.render3D(interpolation)
      EndMode3D()
      self.render2D(interpolation)
      EndDrawing()

  CloseWindow()