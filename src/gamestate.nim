import player
export player

type
  GameState* = object
    player*: Player

proc update*(self: var GameState, inputs: PlayerInputs, delta: float32) =
  self.player.update(inputs, delta)