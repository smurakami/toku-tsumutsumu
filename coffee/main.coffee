enchant()

GAME_WIDTH  = 320;
GAME_HEIGHT = 320;

game = null
toku = null
score = null

Floor = enchant.Class.create PhyBoxSprite,
  initialize: ->
    PhyBoxSprite.call(this, GAME_WIDTH - 20, 40, enchant.box2d.STATIC_SPRITE, 1.0, 1.0, 0.0, true)

    @x = 10
    @y = GAME_HEIGHT - @height/2

    # 輪郭
    surface = new Surface(@width, @height)
    surface.context.beginPath()
    surface.context.strokeRect(0, 0, @width, @height)
    @image = surface

    game.rootScene.addChild(this)


TOKU_DEFAULT_Y = 60
tokuImage = "img/toku_min.png"
Toku = enchant.Class.create PhyBoxSprite,
  initialize: (x=GAME_WIDTH/2, y=TOKU_DEFAULT_Y) ->
    PhyBoxSprite.call(this, 32, 32, enchant.box2d.DYNAMIC_SPRITE, 1.0, 1.0, 0.4, false)
    @image = game.assets[tokuImage]
    @position = {x: x, y:y}
    game.rootScene.addChild(this)

  update: ->


  Score = enchant.Class.create enchant.Label,
    initialize: ->
      enchant.Label.call(this, "徳×0")
      this.num = 0
      this.y = 10
      @font = '32px sans-serif'
      @image = game.assets[tokuImage]
      game.rootScene.addChild(this)
    gain: ->
      this.num++
      this.text = "徳×#{this.num}"


window.onload = ->
  game = enchant.Core(GAME_WIDTH, GAME_HEIGHT)
  game.fps = 30
  game.preload(tokuImage)

  game.onload = ->
    world = new PhysicsWorld(0.0, 25)
    floor = new Floor()
    score = new Score()
    setTimeout ->
      toku = new Toku()
    , 200

    game.rootScene.addEventListener 'touchstart', (e) ->
      if not toku? then return
      toku.position =
        x: e.x
        y: TOKU_DEFAULT_Y


    game.rootScene.addEventListener 'touchmove', (e) ->
      if not toku? then return
      toku.position =
        x: e.x
        y: TOKU_DEFAULT_Y

    game.rootScene.addEventListener 'touchend', ->
      if not toku? then return
      toku.setAwake true
      toku = null
      score.gain()
      setTimeout ->
        toku = new Toku
      , 500

    game.rootScene.onenterframe = (e) ->
      world.step(game.fps)

  game.start()
