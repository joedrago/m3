Animation = require 'Animation'

# -------------------------------------------------------------------

SPRITE_NAMES = [
  # regular gems (powers 1-3)
  "red"
  "green"
  "blue"
  "orange"

  # special gems
  "cyan"
  "bell"
  "pink"
  "broken"
]

Number.prototype.clamp = (min, max) ->
  return Math.min(Math.max(this, min), max)

# ---------------------------------------------------------------------------------------

class Grid
  constructor: (@game) ->
    @game.log "Grid created."
    @MARGIN = 20

    @gemSpeed =
      r: Math.PI * 2
      s: 2.5
      t: 4 * @game.width

    @size = @game.width - (@MARGIN * 2)
    @gemSize = @size / 8
    @x = @MARGIN
    @y = @MARGIN
    @dragX = -1
    @dragY = -1

    @grid = []
    for x in [0...8]
      @grid[x] = []
      for y in [0...8]
        @grid[x].push {
          type: 0
          anim: null
        }
        @randomGem(x, y)

  gridToCoords: (x, y) ->
    return {
      x: @x + (x * @gemSize)
      y: @y + ((7 - y) * @gemSize)
    }

  coordsToGrid: (cx, cy) ->
    cx -= @x
    cy -= @y
    g = {
      x:     Math.floor(cx / @gemSize).clamp(0, 7)
      y: 7 - Math.floor(cy / @gemSize).clamp(0, 7)
    }
    return g

  typeToSprite: (type, power = 1, highlighted = false) ->
    name = SPRITE_NAMES[type]
    if type < 4
      name += power
    if highlighted
      name += "_H"
    return name

  randomGem: (x, y) ->
    coords = @gridToCoords(x, y)
    @grid[x][y].anim = new Animation {
      speed: @gemSpeed
      x: coords.x
      y: coords.y
      r: 0
    }
    @grid[x][y].type = 4

  resetPositions: ->
    for x in [0...8]
      for y in [0...8]
        coords = @gridToCoords(x, y)
        anim = @grid[x][y].anim
        anim.req.x = coords.x
        anim.req.y = coords.y

  update: (dt) ->
    updated = false
    for x in [0...8]
      for y in [0...8]
        if @grid[x][y].anim.update(dt)
          updated = true
    return updated

  select: (x, y, cx, cy) ->
    c = @gridToCoords(x, y)
    # @game.log "click on gem #{x}, #{y}"
    @dragX = x
    @dragY = y
    anim = @grid[@dragX][@dragY].anim
    anim.req.x = c.x
    anim.req.y = c.y

  move: (x, y) ->
    if (@dragX != -1) and (@dragY != -1)
      g = @coordsToGrid(x, y)
      c = @gridToCoords(g.x, g.y)
      # @game.log "g #{g.x}, #{g.y}"
      anim = @grid[@dragX][@dragY].anim
      anim.req.x = c.x
      anim.req.y = c.y

  up: (x, y) ->
    @dragX = -1
    @dragY = -1
    @resetPositions()

  render: ->
    for x in [0...8]
      for y in [0...8]
        if (@dragX != x) or (@dragY != y)
          do (x, y) =>
            gem = @grid[x][y]
            @game.spriteRenderer.render @typeToSprite(gem.type), gem.anim.cur.x, gem.anim.cur.y, @gemSize, @gemSize, 0, 0, 0, @game.colors.white, (cx, cy) =>
              @select(x, y, cx, cy)
    if (@dragX != -1) and (@dragY != -1)
      gem = @grid[@dragX][@dragY]
      @game.spriteRenderer.render @typeToSprite(gem.type+1), gem.anim.cur.x, gem.anim.cur.y, @gemSize, @gemSize, 0, 0, 0, @game.colors.white

module.exports = Grid
