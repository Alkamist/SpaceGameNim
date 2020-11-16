type
  AnalogAxis* = object
    value*: float32
    previousValue*: float32
    deadZone*: float32
    wasActive*: bool
    framesActive*: uint32
    highStateWasFirst: bool

func initAnalogAxis*(deadZone: float32): AnalogAxis =
  result.value = 0.0
  result.previousValue = 0.0
  result.deadZone = 0.2875
  result.wasActive = false
  result.framesActive = 0
  result.highStateWasFirst = true

func direction*(self: AnalogAxis): float32 =
  if self.value > 0.0:
    1.0
  elif self.value < 0.0:
    -1.0
  else:
    0.0

func justCrossedCenter*(self: AnalogAxis): bool =
  (self.value < 0.0 and self.previousValue >= 0.0) or
  (self.value > 0.0 and self.previousValue <= 0.0)

func isActive*(self: AnalogAxis): bool =
  self.value.abs >= self.deadZone

func justActivated*(self: AnalogAxis): bool =
  self.justCrossedCenter or self.isActive and not self.wasActive

func justDeactivated*(self: AnalogAxis): bool =
  self.wasActive and not self.isActive

proc setValueFromStates*(self: var AnalogAxis, lowState: bool, highState: bool) =
  let lowAndHigh = lowState and highState
  let onlyLow = lowState and not highState
  let onlyHigh = highState and not lowState
  if onlyHigh:
    self.highStateWasFirst = true
  elif onlyLow:
    self.highStateWasFirst = false
  if onlyLow or (lowAndHigh and self.highStateWasFirst):
      self.value = -1.0
  elif onlyHigh or (lowAndHigh and not self.highStateWasFirst):
      self.value = 1.0
  else:
      self.value = 0.0

proc update*(self: var AnalogAxis) =
  if self.justActivated:
      self.framesActive = 0
  elif self.isActive:
      self.framesActive += 1
  else:
      self.framesActive = 0

  self.previousValue = self.value
  self.wasActive = self.isActive