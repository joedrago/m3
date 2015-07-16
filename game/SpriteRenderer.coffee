class SpriteRenderer
  constructor: (@game) ->
    @sprites =
      # generic sprites
      solid:     { texture: "tiles", x:   0, y:   0, w:  10, h:  10 }

      broken      : { texture: "gems", x:     4, y:     4, w:    80, h:    80 }
      broken_H    : { texture: "gems", x:     4, y:    88, w:    80, h:    80 }
      pink        : { texture: "gems", x:    88, y:     4, w:    80, h:    80 }
      pink_H      : { texture: "gems", x:    88, y:    88, w:    80, h:    80 }
      cyan        : { texture: "gems", x:   172, y:     4, w:    80, h:    80 }
      cyan_H      : { texture: "gems", x:   172, y:    88, w:    80, h:    80 }
      bell        : { texture: "gems", x:   256, y:     4, w:    80, h:    80 }
      bell_H      : { texture: "gems", x:   256, y:    88, w:    80, h:    80 }
      red1        : { texture: "gems", x:   340, y:     4, w:    80, h:    80 }
      red1_H      : { texture: "gems", x:   340, y:    88, w:    80, h:    80 }
      red2        : { texture: "gems", x:   424, y:     4, w:    80, h:    80 }
      red2_H      : { texture: "gems", x:   424, y:    88, w:    80, h:    80 }
      red3        : { texture: "gems", x:   508, y:     4, w:    80, h:    80 }
      red3_H      : { texture: "gems", x:   508, y:    88, w:    80, h:    80 }
      green1      : { texture: "gems", x:   592, y:     4, w:    80, h:    80 }
      green1_H    : { texture: "gems", x:   592, y:    88, w:    80, h:    80 }
      green2      : { texture: "gems", x:   676, y:     4, w:    80, h:    80 }
      green2_H    : { texture: "gems", x:   676, y:    88, w:    80, h:    80 }
      green3      : { texture: "gems", x:   760, y:     4, w:    80, h:    80 }
      green3_H    : { texture: "gems", x:   760, y:    88, w:    80, h:    80 }
      blue1       : { texture: "gems", x:   844, y:     4, w:    80, h:    80 }
      blue1_H     : { texture: "gems", x:   844, y:    88, w:    80, h:    80 }
      blue2       : { texture: "gems", x:   928, y:     4, w:    80, h:    80 }
      blue2_H     : { texture: "gems", x:   928, y:    88, w:    80, h:    80 }
      blue3       : { texture: "gems", x:  1012, y:     4, w:    80, h:    80 }
      blue3_H     : { texture: "gems", x:  1012, y:    88, w:    80, h:    80 }
      orange1     : { texture: "gems", x:  1096, y:     4, w:    80, h:    80 }
      orange1_H   : { texture: "gems", x:  1096, y:    88, w:    80, h:    80 }
      orange2     : { texture: "gems", x:  1180, y:     4, w:    80, h:    80 }
      orange2_H   : { texture: "gems", x:  1180, y:    88, w:    80, h:    80 }
      orange3     : { texture: "gems", x:  1264, y:     4, w:    80, h:    80 }
      orange3_H   : { texture: "gems", x:  1264, y:    88, w:    80, h:    80 }


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
