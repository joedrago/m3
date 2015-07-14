class SpriteRenderer
  constructor: (@game) ->
    @sprites =
      # generic sprites
      solid:     { texture: "tiles", x:   0, y:   0, w:  10, h:  10 }

  calcWidth: (spriteName, height) ->
    sprite = @sprites[spriteName]
    return 1 if not sprite
    return height * sprite.w / sprite.h

  render: (spriteName, dx, dy, dw, dh, rot, anchorx, anchory, color, cb) ->
    sprite = @sprites[spriteName]
    return if not sprite
    if (dw == 0) and (dh == 0)
      # this probably shouldn't ever be used.
      dw = sprite.x
      dh = sprite.y
    else if dw == 0
      dw = dh * sprite.w / sprite.h
    else if dh == 0
      dh = dw * sprite.h / sprite.w
    @game.drawImage sprite.texture, sprite.x, sprite.y, sprite.w, sprite.h, dx, dy, dw, dh, rot, anchorx, anchory, color.r, color.g, color.b, color.a, cb
    return

module.exports = SpriteRenderer
