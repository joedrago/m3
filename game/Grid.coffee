Animation = require 'Animation'

# -------------------------------------------------------------------

SPRITE_NAMES = [
  # regular gems (powers 1-3)
  "red"
  "green"
  "blue"
  "orange"

  # special gems
  "bell"
  "pink"
  "broken"
  #"cyan"
]

GEM_TYPES =
  RED: 0
  GREEN: 1
  BLUE: 2
  ORANGE: 3
  BELL: 4
  PINK: 5
  BROKEN: 6
  CYAN: 7

Number.prototype.clamp = (min, max) ->
  return Math.min(Math.max(this, min), max)

# ---------------------------------------------------------------------------------------

class Grid
  constructor: (@game) ->
    @game.log "Grid created."

    # Constants / Metrics
    @MARGIN = 10
    @IDLE_SCALE = 0.9
    @SELECTED_SCALE = 1
    @SHATTER_TIME = 1000
    @gemSpeed =
      r: Math.PI * 2
      s: 2.5
      t: 2 * @game.width
    @size = @game.width - (@MARGIN * 2)
    @gemSize = Math.floor(@size / 8)
    @gemSizeHalf = @gemSize >> 1
    @x = @MARGIN
    @y = @game.height - ((@gemSize * 10) + @MARGIN)
    @centerX = @x + (@gemSize * 4)
    @centerY = @y + (@gemSize * 4)

    @shattered = []

    @newGame()

  newGame: ->
    @grid = []
    @nextGrid = []
    for x in [0...8]
      @grid[x] = []
      @fillColumn(x)
      @nextGrid[x] = []
      for y in [0...8]
        @nextGrid[x].push null

    @resetDrag()
    while @scoreGrid(@grid)
      @shatter()
    @resetPositions(@grid)
    @resetScores(@grid)
    @warp()
    @shattered = []

    @turns = 20
    @progress = 0
    @animating = false

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

  randomGem: (x) ->
    if @grid[x].length < 8
      @grid[x].push {
        type: 0
        power: 1
        anim: null
        score: 0
      }
      y = @grid[x].length - 1
      coords = @gridToCoords(x, y)
      anim = new Animation {
        speed: @gemSpeed
        x: coords.x
        y: coords.y - (@gemSize * y)
        r: 0
        s: @IDLE_SCALE
      }
      anim.req.y = coords.y
      @grid[x][y].anim = anim
      @grid[x][y].type = Math.floor(Math.random() * SPRITE_NAMES.length)

  fillColumn: (x) ->
    while @grid[x].length < 8
      @randomGem(x)

  warp: ->
    for x in [0...8]
      for y in [0...8]
        @grid[x][y].anim.warp()

  resetDrag: ->
    @dragSrcX = -1
    @dragSrcY = -1
    @dragDstX = -1
    @dragDstY = -1

  resetPositions: (grid) ->
    for x in [0...8]
      for y in [0...8]
        coords = @gridToCoords(x, y)
        anim = grid[x][y].anim
        anim.req.x = coords.x
        anim.req.y = coords.y
        if grid[x][y].score > 0
          anim.req.s = @SELECTED_SCALE
        else
          anim.req.s = @IDLE_SCALE

  resetScores: (grid) ->
    for x in [0...8]
      for y in [0...8]
        grid[x][y].score = 0

  runLength: (grid, x, y, dx, dy) ->
    len = 1
    type = grid[x][y].type
    loop
      x += dx
      y += dy
      break if x < 0
      break if y < 0
      break if x >= 8
      break if y >= 8
      break if grid[x][y].type != type
      len += 1
    return len

  scoreRun: (grid, x, y, dx, dy, len, score = 1) ->
    while len
      grid[x][y].score += score
      x += dx
      y += dy
      len -= 1
    return

  scoreGrid: (grid) ->
    @resetScores(grid)
    hasMatch = false

    for y in [0...8]
      x = 0
      while x < 6
        len = @runLength(grid, x, y, 1, 0)
        if len >= 3
          hasMatch = true
          @scoreRun(grid, x, y, 1, 0, len, len)
          x += len
        else
          x += 1

    for x in [0...8]
      y = 0
      while y < 6
        len = @runLength(grid, x, y, 0, 1)
        if len >= 3
          hasMatch = true
          @scoreRun(grid, x, y, 0, 1, len, len)
          y += len
        else
          y += 1

    return hasMatch

  shatter: ->
    group =
      list: []
    regularGemTotal = 0
    extraTurns = 0
    for x in [0...8]
      newColumn = []
      for y in [0...8]
        if @grid[x][y].score > 0
          switch @grid[x][y].type
            when GEM_TYPES.RED, GEM_TYPES.GREEN, GEM_TYPES.BLUE, GEM_TYPES.ORANGE
              regularGemTotal += Math.max(@grid[x][y].score - 2, 1)
            when GEM_TYPES.BELL
              extraTurns += 1
          group.list.push {
            x: x
            y: y
            type: @grid[x][y].type
            power: @grid[x][y].power
          }
        else
          newColumn.push @grid[x][y]
      @grid[x] = newColumn
      @fillColumn(x)

    if group.list.length > 0
      group.timer = @SHATTER_TIME
      group.color = { r: 1, g: 1, b: 1, a: 1 }
      group.rot = 0
      @updateShatterGroup(group)
      @shattered.push group

    # Update the meta game with this round of shattered spoils
    @progress += regularGemTotal
    @turns += 1 + (extraTurns >> 1)

  updateShatterGroup: (group) ->
    t = 1.0 - (group.timer / @SHATTER_TIME)
    group.scale = 1 + t
    group.color.a = 1 - t
    group.rot = Math.PI * t
    return

  dist: (a, b) ->
    return Math.abs(a - b)

  direction: (src, dst) ->
    diff = dst - src
    if diff > 0
      return 1
    else if diff < 0
      return -1
    return 0

  update: (dt) ->
    updated = false
    for x in [0...8]
      for y in [0...8]
        if @grid[x][y].anim.update(dt)
          updated = true

    remainingShattered = []
    for group in @shattered
      group.timer -= dt
      if group.timer > 0
        @updateShatterGroup(group)
        remainingShattered.push group
    @shattered = remainingShattered

    if (@dragSrcX == -1) and (@dragSrcY == -1)
      if @animating and not updated
        # animations just finished and we're not dragging. Check for chains.
          @game.log "anims finished, checking for match"
          hasMatch = @scoreGrid(@grid)
          if hasMatch
            @game.log "match found, shattering"
            @shatter()
            @resetPositions(@grid)
            @resetScores(@grid)
            updated = true
          else
            @game.log "no match found"

    @animating = updated
    return updated

  select: (x, y, cx, cy) ->
    return if @turns == 0
    return if @animating

    @dragSrcX = x
    @dragSrcY = y
    @dragDstX = x
    @dragDstY = y
    @move(cx, cy)

  move: (x, y) ->
    if (@dragSrcX == -1) or (@dragSrcY == -1)
      return false

    g = @coordsToGrid(x, y)
    if @dist(g.x, @dragSrcX) > @dist(g.y, @dragSrcY)
      g.y = @dragSrcY
    else
      g.x = @dragSrcX
    @dragDstX = g.x
    @dragDstY = g.y

    for x in [0...8]
      for y in [0...8]
        @nextGrid[x][y] = @grid[x][y]
    dx = @direction(@dragSrcX, @dragDstX)
    dy = @direction(@dragSrcY, @dragDstY)
    currX = @dragSrcX
    currY = @dragSrcY
    while (currX != @dragDstX) || (currY != @dragDstY)
      tempGem = @nextGrid[currX][currY]
      @nextGrid[currX][currY] = @nextGrid[currX+dx][currY+dy]
      @nextGrid[currX+dx][currY+dy] = tempGem
      currX += dx
      currY += dy
    @resetPositions(@nextGrid)
    @grid[@dragSrcX][@dragSrcY].anim.req.s = @SELECTED_SCALE
    hasMatch = @scoreGrid(@nextGrid)

    return hasMatch

  up: (x, y) ->
    hasMatch = @move(x, y)
    if hasMatch
      @turns -= 1
      [@grid, @nextGrid] = [@nextGrid, @grid]
      @shatter()

    @resetDrag()
    @resetPositions(@grid)
    @resetScores(@grid)

  render: ->
    textHeight = @gemSize >> 1
    for x in [0...8]
      for y in [0...8]
        do (x, y) =>
          gem = @grid[x][y]
          highlighted = (gem.score > 0) and not @animating
          color = @game.colors.white
          # if highlighted
          #   color = @game.colors.highlight
          @game.spriteRenderer.render @typeToSprite(gem.type, gem.power),
            gem.anim.cur.x + @gemSizeHalf, gem.anim.cur.y + @gemSizeHalf,
            @gemSize * gem.anim.cur.s, @gemSize * gem.anim.cur.s,
            0,
            0.5, 0.5,
            color,
            (cx, cy) =>
              @select(x, y, cx, cy)

          # if highlighted
          #   @game.fontRenderer.render @game.font, textHeight, "#{gem.score}", gem.anim.cur.x + @gemSizeHalf, gem.anim.cur.y + @gemSizeHalf, 0.5, 0.5, @game.colors.white
          # if highlighted

    for group in @shattered
      for gem in group.list
        coords = @gridToCoords(gem.x, gem.y)
        @game.spriteRenderer.render @typeToSprite(gem.type, gem.power),
          coords.x + @gemSizeHalf, coords.y + @gemSizeHalf,
          @gemSize * group.scale, @gemSize * group.scale,
          group.rot,
          0.5, 0.5,
          group.color


    @game.fontRenderer.render @game.font, textHeight, "Turns: #{@turns}", 0, 0, 0, 0, @game.colors.white
    @game.fontRenderer.render @game.font, textHeight, "Progress: #{@progress}", 0, textHeight, 0, 0, @game.colors.white

    if not @animating and @turns == 0
      @game.spriteRenderer.render "solid", 0, 0, @game.width, @game.height, 0, 0, 0, @game.colors.clear, (x, y) =>
        @game.log "new game!"
        @newGame()

      @game.fontRenderer.render @game.font, textHeight * 3, "Failure!", @centerX, @centerY, 0.5, 0.5, @game.colors.red
      @game.fontRenderer.render @game.font, textHeight, "Click for a new game", @centerX, @centerY + (textHeight * 2), 0.5, 0.5, @game.colors.yellow

module.exports = Grid
