type
  AnalogAxis* = object
    value*: float32
    previousValue*: float32
    deadZone*: float32
    wasActive*: bool
    highStateWasFirst: bool

{.push inline.}

proc initAnalogAxis*(deadZone: float32): AnalogAxis =
  result.value = 0.0
  result.previousValue = 0.0
  result.deadZone = 0.2875
  result.wasActive = false
  result.highStateWasFirst = true

proc direction*(axis: AnalogAxis): float32 =
  if axis.value > 0.0:
    1.0
  elif axis.value < 0.0:
    -1.0
  else:
    0.0

proc justCrossedCenter*(axis: AnalogAxis): bool =
  (axis.value < 0.0 and axis.previousValue >= 0.0) or
  (axis.value > 0.0 and axis.previousValue <= 0.0)

proc isActive*(axis: AnalogAxis): bool =
  axis.value.abs >= axis.deadZone

proc justActivated*(axis: AnalogAxis): bool =
  axis.justCrossedCenter or axis.isActive and not axis.wasActive

proc justDeactivated*(axis: AnalogAxis): bool =
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

proc update*(axis: var AnalogAxis) =
  axis.previousValue = axis.value
  axis.wasActive = axis.isActive

{.pop.}