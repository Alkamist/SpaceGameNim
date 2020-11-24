import gameengine/button
import gameengine/analogaxis


type
  GameControls* = object
    xAxis*: AnalogAxis
    yAxis*: AnalogAxis
    jump*: Button

  GameInputs* = object
    left*: bool
    right*: bool
    down*: bool
    up*: bool
    jump*: bool

proc update*(controls: var GameControls) =
  for field in controls.fields:
    field.update()

proc applyInputs*(controls: var GameControls, inputs: GameInputs) =
  controls.xAxis.setValueFromStates(inputs.left, inputs.right)
  controls.yAxis.setValueFromStates(inputs.down, inputs.up)
  controls.jump.isPressed = inputs.jump