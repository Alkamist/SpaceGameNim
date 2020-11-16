import button
import analogaxis

type
  PlayerControls* = object
    xAxis*: AnalogAxis
    yAxis*: AnalogAxis
    jump*: Button

  PlayerInputs* = object
    left*: bool
    right*: bool
    down*: bool
    up*: bool
    jump*: bool

proc update*(self: var PlayerControls) =
  for field in self.fields:
    field.update()

proc applyInputs*(self: var PlayerControls, inputs: PlayerInputs) =
  self.xAxis.setValueFromStates(inputs.left, inputs.right)
  self.yAxis.setValueFromStates(inputs.down, inputs.up)
  self.jump.isPressed = inputs.jump

type
  Player* = object
    x*: float32
    y*: float32
    xVelocity*: float32
    yVelocity*: float32
    controls: PlayerControls

proc update*(self: var Player, inputs: PlayerInputs, delta: float32) =
  self.controls.update()
  self.controls.applyInputs(inputs)

  self.xVelocity = self.controls.xAxis.value * 10.0
  self.yVelocity = self.controls.yAxis.value * 10.0

  self.x += self.xVelocity * delta
  self.y += self.yVelocity * delta