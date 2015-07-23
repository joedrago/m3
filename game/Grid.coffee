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
    }
    @grid[x][y].type = Math.floor(Math.random() * 8)

  resetPositions: (grid) ->
    for x in [0...8]
      for y in [0...8]
        coords = @gridToCoords(x, y)
        anim = grid[x][y].anim
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
    @dragSrcX = x
    @dragSrcY = y
    @dragDstX = x
    @dragDstY = y
    anim = @grid[@dragSrcX][@dragSrcY].anim
    anim.req.x = c.x
    anim.req.y = c.y

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
      c = @gridToCoords(g.x, g.y)
      # @game.log "g #{g.x}, #{g.y}"
      anim = @grid[@dragSrcX][@dragSrcY].anim
      anim.req.x = c.x
      anim.req.y = c.y

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
          @game.spriteRenderer.render @typeToSprite(gem.type, gem.power, highlighted), gem.anim.cur.x, gem.anim.cur.y, @gemSize, @gemSize, 0, 0, 0, @game.colors.white, (cx, cy) =>
            @select(x, y, cx, cy)

    # if (@dragSrcX != -1) and (@dragSrcY != -1)
    #   gem = @grid[@dragSrcX][@dragSrcY]
    #   @game.spriteRenderer.render @typeToSprite(gem.type), gem.anim.cur.x, gem.anim.cur.y, @gemSize, @gemSize, 0, 0, 0, @game.colors.white
    #   # @game.log "drawing @dragSrcX #{@dragSrcX}, @dragSrcY #{@dragSrcY}"

module.exports = Grid
