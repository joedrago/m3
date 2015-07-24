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
    @IDLE_SCALE = 0.95
    @SELECTED_SCALE = 1.15

    @gemSpeed =
      r: Math.PI * 2
      s: 2.5
      t: 3 * @game.width

    @size = @game.width - (@MARGIN * 2)
    @gemSize = Math.floor(@size / 8)
    @gemSizeHalf = @gemSize >> 1
    @x = @MARGIN
    @y = @MARGIN
    @resetDrag()

    @grid = []
    for x in [0...8]
      @grid[x] = []
      for y in [0...8]
        @grid[x].push {
          type: 0
          anim: null
        }
        @randomGem(x, y)

    @futureGrid = []
    for x in [0...8]
      @futureGrid[x] = []
      for y in [0...8]
        @futureGrid[x].push null

  resetDrag: ->
    @dragSrcX = -1
    @dragSrcY = -1
    @dragDstX = -1
    @dragDstY = -1

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
      s: 1
    }
    @grid[x][y].type = Math.floor(Math.random() * 8)

  resetPositions: (grid) ->
    for x in [0...8]
      for y in [0...8]
        coords = @gridToCoords(x, y)
        anim = grid[x][y].anim
        anim.req.x = coords.x
        anim.req.y = coords.y
        anim.req.s = @IDLE_SCALE

  update: (dt) ->
    updated = false
    for x in [0...8]
      for y in [0...8]
        if @grid[x][y].anim.update(dt)
          updated = true
    return updated

  select: (x, y, cx, cy) ->
    @dragSrcX = x
    @dragSrcY = y
    @dragDstX = x
    @dragDstY = y
    @move(cx, cy)

  dist: (a, b) ->
    return Math.abs(a - b)

  direction: (src, dst) ->
    diff = dst - src
    if diff > 0
      return 1
    else if diff < 0
      return -1
    return 0

  move: (x, y) ->
    if (@dragSrcX != -1) and (@dragSrcY != -1)
      g = @coordsToGrid(x, y)
      if @dist(g.x, @dragSrcX) > @dist(g.y, @dragSrcY)
        g.y = @dragSrcY
      else
        g.x = @dragSrcX
      @dragDstX = g.x
      @dragDstY = g.y

      for x in [0...8]
        for y in [0...8]
          @futureGrid[x][y] = @grid[x][y]
      dx = @direction(@dragSrcX, @dragDstX)
      dy = @direction(@dragSrcY, @dragDstY)
      currX = @dragSrcX
      currY = @dragSrcY
      @game.log "START"
      while (currX != @dragDstX) || (currY != @dragDstY)
        @game.log "GO #{currX}, #{currY} (#{dx}, #{dy})"
        tempGem = @futureGrid[currX][currY]
        @futureGrid[currX][currY] = @futureGrid[currX+dx][currY+dy]
        @futureGrid[currX+dx][currY+dy] = tempGem
        currX += dx
        currY += dy
      @game.log "dx #{dx}, dy #{dy}"
      @resetPositions(@futureGrid)
      @grid[@dragSrcX][@dragSrcY].anim.req.s = @SELECTED_SCALE

  up: (x, y) ->
    @resetDrag()
    @resetPositions(@grid)

  render: ->
    # if (@dragDstX != -1) and (@dragDstY != -1)
    #   gem2 = @grid[@dragDstX][@dragDstY]
    #   @game.spriteRenderer.render @typeToSprite(gem2.type+2), gem2.anim.cur.x, gem2.anim.cur.y, @gemSize, @gemSize, 0, 0, 0, @game.colors.white
    #   # @game.log "drawing @dragDstX #{@dragDstX}, @dragDstY #{@dragDstY}"

    for x in [0...8]
      for y in [0...8]
        highlighted = ! (( (@dragSrcX != x) or (@dragSrcY != y) ) and  ( (@dragDstX != x) or (@dragDstY != y) ))
        do (x, y, highlighted) =>
          gem = @grid[x][y]
          @game.spriteRenderer.render @typeToSprite(gem.type, gem.power, highlighted),
            gem.anim.cur.x + @gemSizeHalf, gem.anim.cur.y + @gemSizeHalf,
            @gemSize * gem.anim.cur.s, @gemSize * gem.anim.cur.s,
            0,
            0.5, 0.5,
            @game.colors.white,
            (cx, cy) =>
              @select(x, y, cx, cy)

    # if (@dragSrcX != -1) and (@dragSrcY != -1)
    #   gem = @grid[@dragSrcX][@dragSrcY]
    #   @game.spriteRenderer.render @typeToSprite(gem.type), gem.anim.cur.x, gem.anim.cur.y, @gemSize, @gemSize, 0, 0, 0, @game.colors.white
    #   # @game.log "drawing @dragSrcX #{@dragSrcX}, @dragSrcY #{@dragSrcY}"

module.exports = Grid
