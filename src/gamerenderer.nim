import fixedtimestep
import raylib
import vmath
import gamestate

type
  GameRenderer* = object
    gameState*: GameState
    previousGameState*: GameState
    displayFps*: float32
    windowTitle*: cstring
    windowWidth*: int32
    windowHeight*: int32
    zoom: float32
    fixedTimestep*: FixedTimestep

func initGameRenderer*(
  windowTitle: cstring,
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
  result.zoom = 64.0
  result.fixedTimestep = initFixedTimestep(physicsFps)

func toScreenPosition(self: GameRenderer, position: Vec2): Vec2 =
  result.x = self.windowWidth.float32 * 0.5 + position.x * self.zoom
  result.y = self.windowHeight.float32 * 0.5 - position.y * self.zoom

#func drawPlayer(self: GameRenderer) =
#  let
#    width = 40
#    height = 80
#    previousPosition = vec2(self.previousGameState.player.x, self.previousGameState.player.y)
#    position = vec2(self.gameState.player.x, self.gameState.player.y)
#    interpolatedPosition = previousPosition.lerp(position, self.fixedTimestep.interpolation)
#    playerX = interpolatedPosition.x
#    playerY = interpolatedPosition.y
#    screenX = int32(self.windowWidth.float32 * 0.5 + playerX * self.zoom) - int32(width.float32 * 0.5)
#    screenY = int32(self.windowHeight.float32 * 0.5 - playerY * self.zoom) - height
#
#  DrawRectangle(screenX, screenY, width, height, MAROON)

func drawPolygon(self: GameRenderer, polygon: CollisionPolygon) =
  let numPoints = polygon.numberOfSides
  if numPoints > 2:
    for i in 0..<numPoints:
      let
        startPosition = self.toScreenPosition(polygon.worldPoints[i])
        endPosition = self.toScreenPosition(polygon.worldPoints[(i + 1) mod numPoints])
      DrawLine(startPosition.x.int32,
               startPosition.y.int32,
               endPosition.x.int32,
               endPosition.y.int32,
               if polygon.isOverlapped: RED else: GREEN)

proc updateGameState(self: var GameRenderer) =
  self.previousGameState = self.gameState

  let inputs = PlayerInputs(
    left: IsKeyDown(KEY_A),
    right: IsKeyDown(KEY_D),
    down: IsKeyDown(KEY_S),
    up: IsKeyDown(KEY_W),
    jump: IsKeyDown(KEY_SPACE),
  )

  self.gameState.update(inputs, self.fixedTimestep.physicsDelta)

func render(self: GameRenderer) =
  ClearBackground(BLACK)

  #self.drawPlayer()

  for polygon in self.gameState.collisionGroup.colliders:
    self.drawPolygon(polygon)

  DrawFPS(10, 10)

proc run*(self: var GameRenderer) =
  InitWindow(self.windowWidth, self.windowHeight, self.windowTitle)
  SetTargetFPS(self.displayFps.int32)

  while not WindowShouldClose():
    self.fixedTimestep.update:
      self.updateGameState()

    BeginDrawing()
    self.render()
    EndDrawing()

  CloseWindow()