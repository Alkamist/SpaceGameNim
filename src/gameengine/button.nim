type
  Button* = object
    isPressed*: bool
    wasPressed*: bool

proc update*(button: var Button) {.inline.} =
  button.wasPressed = button.isPressed

func justPressed*(button: Button): bool {.inline.} =
  button.isPressed and not button.wasPressed

func justReleased*(button: Button): bool {.inline.} =
  button.wasPressed and not button.isPressed