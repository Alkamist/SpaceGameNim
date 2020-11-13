import std/monotimes
import std/times

template runGameWhile*(
  condition: bool,
  updateFrequency: float32,
  body: untyped): untyped =

  block:
    var
      startTime = getMonoTime()
      previousTime = getMonoTime()
      lag: float32 = 0.0

    while condition:
      let
        currentTime = getMonoTime()
        delta {.inject.} = float32(inMilliseconds(currentTime - previousTime).float64 * 0.001)

      previousTime = currentTime
      lag += delta

      let
        time {.inject.} = inMilliseconds(currentTime - startTime).float64 * 0.001
        secondsPerUpdate {.inject.} = 1'f32 / updateFrequency

      template update(updateBody: untyped): untyped {.inject.} =
        block:
          while lag >= secondsPerUpdate:
            updateBody
            lag -= secondsPerUpdate

      template draw(stepName, drawBody: untyped): untyped {.inject.} =
        block:
          let stepName {.inject.} = lag / secondsPerUpdate
          drawBody

      body