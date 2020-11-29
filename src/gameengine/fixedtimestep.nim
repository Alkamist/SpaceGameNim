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

proc initFixedTimestep*(physicsFps: float32): FixedTimestep =
  result.interpolation = 0.0
  result.displayDelta = 0.0
  result.physicsDelta = 1.0 / physicsFps
  result.accumulator = 0.0
  result.currentTime = getMonoTime()
  result.previousTime = getMonoTime()

template update*(step: var FixedTimestep, updateStatement: typed) =
  step.currentTime = getMonoTime()

  step.displayDelta = (inMilliseconds(step.currentTime - step.previousTime).float64 * 0.001).float32
  step.accumulator += step.displayDelta

  while step.accumulator >= step.physicsDelta:
    updateStatement
    step.accumulator -= step.physicsDelta

  step.interpolation = step.accumulator / step.physicsDelta

  step.previousTime = step.currentTime