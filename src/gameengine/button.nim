type
  Button* = object
    isPressed*: bool
    wasPressed*: bool

proc update*(button: var Button) =
  button.wasPressed = button.isPressed

func justPressed*(button: Button): bool =
  button.isPressed and not button.wasPressed

func justReleased*(button: Button): bool =
  button.wasPressed and not button.isPressed