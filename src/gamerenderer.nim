import raylib
import gamestate
import gameengine/fixedtimestep
import gameengine/math2d


type
  GameRenderer* = object
    gameState*: GameState
    previousGameState*: GameState
    displayFps*: float32
    windowTitle*: cstring
    windowWidth*: int32
    windowHeight*: int32
    cameraZoom: float32
    fixedTimestep*: FixedTimestep

func initGameRenderer*(windowTitle: cstring,
                       windowWidth: int32,
                       windowHeight: int32,
                       displayFps: float32,
                       physicsFps: float32): GameRenderer =
  result.gameState = initGameState()
  result.previousGameState = initGameState()
  result.displayFps = displayFps
  result.windowTitle = windowTitle
  result.windowWidth = windowWidth
  result.windowHeight = windowHeight
  result.cameraZoom = 64.0
  result.fixedTimestep = initFixedTimestep(physicsFps)

func toScreenPosition(renderer: GameRenderer, position: Vector2d): Vector2d =
  result.x = renderer.windowWidth.float32 * 0.5 + position.x * renderer.cameraZoom
  result.y = renderer.windowHeight.float32 * 0.5 - position.y * renderer.cameraZoom

func drawCollider(renderer: GameRenderer, body: CollisionBody2d) =
  let numSides = body.numberOfSides
  if numSides > 2:
    for i in 0..<numSides:
      let
        startPosition = renderer.toScreenPosition(body.worldPolygon.points[i])
        endPosition = renderer.toScreenPosition(body.worldPolygon.points[(i + 1) mod numSides])
      DrawLine(startPosition.x.int32,
               startPosition.y.int32,
               endPosition.x.int32,
               endPosition.y.int32,
               if body.isOverlapped: RED else: GREEN)

proc updateGameState(renderer: var GameRenderer) =
  renderer.previousGameState = renderer.gameState

  let inputs = GameInputs(left: IsKeyDown(KEY_A),
                          right: IsKeyDown(KEY_D),
                          down: IsKeyDown(KEY_S),
                          up: IsKeyDown(KEY_W),
                          jump: IsKeyDown(KEY_SPACE))

  renderer.gameState.update(inputs, renderer.fixedTimestep.physicsDelta)

func render(renderer: GameRenderer) =
  ClearBackground(BLACK)

  for collider in renderer.gameState.colliders:
    renderer.drawCollider(collider)

  DrawFPS(10, 10)

proc run*(renderer: var GameRenderer) =
  InitWindow(renderer.windowWidth, renderer.windowHeight, renderer.windowTitle)
  SetTargetFPS(renderer.displayFps.int32)

  while not WindowShouldClose():
    renderer.fixedTimestep.update:
      renderer.updateGameState()

    BeginDrawing()
    renderer.render()
    EndDrawing()

  CloseWindow()