type
  AnalogAxis* = object
    value*: float32
    previousValue*: float32
    deadZone*: float32
    wasActive*: bool
    highStateWasFirst: bool

func initAnalogAxis*(deadZone: float32): AnalogAxis =
  result.value = 0.0
  result.previousValue = 0.0
  result.deadZone = 0.2875
  result.wasActive = false
  result.highStateWasFirst = true

func direction*(axis: AnalogAxis): float32 {.inline.} =
  if axis.value > 0.0:
    1.0
  elif axis.value < 0.0:
    -1.0
  else:
    0.0

func justCrossedCenter*(axis: AnalogAxis): bool {.inline.} =
  (axis.value < 0.0 and axis.previousValue >= 0.0) or
  (axis.value > 0.0 and axis.previousValue <= 0.0)

func isActive*(axis: AnalogAxis): bool {.inline.} =
  axis.value.abs >= axis.deadZone

func justActivated*(axis: AnalogAxis): bool {.inline.} =
  axis.justCrossedCenter or axis.isActive and not axis.wasActive

func justDeactivated*(axis: AnalogAxis): bool {.inline.} =
  axis.wasActive and not axis.isActive

proc setValueFromStates*(axis: var AnalogAxis, lowState: bool, highState: bool) =
  let lowAndHigh = lowState and highState
  let onlyLow = lowState and not highState
  let onlyHigh = highState and not lowState
  if onlyHigh:
    axis.highStateWasFirst = true
  elif onlyLow:
    axis.highStateWasFirst = false
  if onlyLow or (lowAndHigh and axis.highStateWasFirst):
      axis.value = -1.0
  elif onlyHigh or (lowAndHigh and not axis.highStateWasFirst):
      axis.value = 1.0
  else:
      axis.value = 0.0

proc update*(axis: var AnalogAxis) {.inline.} =
  axis.previousValue = axis.value
  axis.wasActive = axis.isActive