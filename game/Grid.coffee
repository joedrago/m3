SpriteRenderer = require 'SpriteRenderer'

class Grid
  constructor: (@game) ->
    @game.log "Grid created."

  update: (dt) ->
    return false

  render: ->
    # gemSize = @width / 8
    # for x in [0...8]
    #   for y in [0...8]
    #     @spriteRenderer.render @gemNames[ @grid[x][y] ], x * (gemSize), y * (gemSize), gemSize, gemSize, 0, 0, 0, @colors.white

module.exports = Grid


    # @gemNames = [
    #   "broken"
    #   "bell"
    #   "pink"
    #   "cyan"
    #   "red1"
    #   "green1"
    #   "blue1"
    #   "orange1"
    # ]
    # gemCount = @gemNames.length
    # @grid = []
    # for col in [0...8]
    #   @grid[col] = []
    #   for y in [0...8]
    #     @grid[col][y] = Math.floor(Math.random() * gemCount)
