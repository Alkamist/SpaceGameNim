type
  Button* = object
    isPressed*: bool
    wasPressed*: bool

proc update*(self: var Button) =
  self.wasPressed = self.isPressed

func justPressed*(self: Button): bool =
  self.isPressed and not self.wasPressed

func justReleased*(self: Button): bool =
  self.wasPressed and not self.isPressed