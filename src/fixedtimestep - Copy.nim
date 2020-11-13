import times

type
  FixedTimestep* = object
    interpolation*: float
    physicsDeltaDuration*: Duration
    physicsDelta*: float
    accumulator: Duration

func initFixedTimestep*(physicsFps: float): FixedTimestep =
  return FixedTimestep(
    interpolation: 0.0,
    physicsDeltaDuration: initDuration(nanoseconds=(1_000_000_000.0 / physicsFps).int64),
    physicsDelta: 1.0 / physicsFps,
    accumulator: initDuration(seconds=0),
  )

template update*(self: var FixedTimestep, deltaDuration: Duration, updateStatement: typed) =
  self.accumulator += deltaDuration

  while self.accumulator >= self.physicsDeltaDuration:
    updateStatement
    self.accumulator -= self.physicsDeltaDuration

  var accumulatorFloat = self.accumulator.inNanoseconds.float / 1_000_000_000.0
  self.interpolation = accumulatorFloat / self.physicsDelta