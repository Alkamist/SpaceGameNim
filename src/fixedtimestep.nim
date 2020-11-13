import std/times
import std/monotimes

type
  FixedTimestep* = object
    interpolation*: float32
    displayDelta*: float32
    physicsDelta*: float32
    accumulator: float32
    currentTime: MonoTime
    previousTime: MonoTime

func initFixedTimestep*(physicsFps: float32): FixedTimestep =
  result.interpolation = 0.0
  result.displayDelta = 0.0
  result.physicsDelta = 1.0 / physicsFps
  result.accumulator = 0.0
  result.currentTime = getMonoTime()
  result.previousTime = getMonoTime()

template update*(self: var FixedTimestep, updateStatement: typed) =
  self.currentTime = getMonoTime()

  self.displayDelta = (inMilliseconds(self.currentTime - self.previousTime).float64 * 0.001).float32
  self.accumulator += self.displayDelta

  while self.accumulator >= self.physicsDelta:
    updateStatement
    self.accumulator -= self.physicsDelta

  self.interpolation = self.accumulator / self.physicsDelta

  self.previousTime = self.currentTime