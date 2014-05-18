enchant()

GAME_WIDTH  = 320;
GAME_HEIGHT = 320;

game = null
toku = null
score = null
gameIsOver = false

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
MOVE_TOP_THRESHOLD = 100
Toku = enchant.Class.create PhyBoxSprite,
  initialize: (x=GAME_WIDTH/2, y=TOKU_DEFAULT_Y) ->
    if gameIsOver then return
    PhyBoxSprite.call(this, 32, 32, enchant.box2d.DYNAMIC_SPRITE, 1.0, 1.0, 0.4, false)
    @image = game.assets[tokuImage]
    x -= game.rootScene.x
    y -= game.rootScene.y
    @position = {x: x, y:y}
    @addEventListener('enterframe', @update)
    game.rootScene.addChild(this)

  checkPos: ->
    self = this
    setTimeout ->
      # console.log "self.y: #{self.y}"
      # console.log "game.rootScene.y: #{game.rootScene.y}"
      # console.log "MOVE_TOP_THRESHOLD: #{MOVE_TOP_THRESHOLD}"
      # console.log "minus: #{- game.rootScene.y + MOVE_TOP_THRESHOLD}"
      if self.y < -game.rootScene.y + MOVE_TOP_THRESHOLD
        setGamePos(0, game.rootScene.y + MOVE_TOP_THRESHOLD)
    , 500

  update: ->
    if gameIsOver
      @destroy()
      return
    if @y > GAME_HEIGHT + @height
      gameover()

  destroy: ->
    @removeEventListener("enterframe", @update)
    game.rootScene.removeChild(this)


Score = enchant.Class.create enchant.Label,
  initialize: ->
    enchant.Label.call(this, "徳×0")
    this.num = 0
    this.x = 10
    this.y = 10
    @font = '32px sans-serif'
    @image = game.assets[tokuImage]
    game.rootScene.addChild(this)
  gain: ->
    this.num++
    this.text = "徳×#{this.num}"


titleImage = 'img/title.png'
Title = enchant.Class.create enchant.Sprite,
  initialize: ->
    enchant.Sprite.call(this, GAME_WIDTH, GAME_HEIGHT)
    @image = game.assets[titleImage]
    @addEventListener 'touchstart', ->
      game.rootScene.removeChild(this)
      setTimeout ->
        toku = new Toku()
      , 200
    game.rootScene.addChild(this)


EndScreen = enchant.Class.create enchant.Sprite,
  initialize: ->
    enchant.Sprite.call(this, GAME_WIDTH, GAME_HEIGHT)
    self = this
    this.backgroundColor = "#fff"
    game.rootScene.addChild(this)
    endLabel = new Label("おしまい")
    endLabel.font = '60px メイリオ'
    endLabel.x = 40
    endLabel.y = 40
    game.rootScene.addChild(endLabel)

    scoreLabel = new Label("つんだ徳: ")
    scoreLabel.font = '26px メイリオ'
    scoreLabel.x = 40
    scoreLabel.y = 160
    game.rootScene.addChild(scoreLabel)

    setTimeout ->
      label = new Label("#{score.num}")
      label.font = '80px sans-serif'
      label.x = 160
      label.y = 120
      game.rootScene.addChild(label)
    , 1000

    setTimeout ->
      award = awardTitle(score.num)
      label = new Label("称号: #{award}")
      label.font = '40px sans-serif'
      label.x = 40
      label.y = 220
      game.rootScene.addChild(label)
    , 2000

    setTimeout ->
      award = awardTitle(score.num)
      label = new Label("クリックでもういちど")
      label.font = '20px sans-serif'
      label.x = 40
      label.y = 280
      game.rootScene.addChild(label)
      game.rootScene.addEventListener 'touchstart', ->
        window.location.reload()
    , 3000


awards = [
  "プー太郎",
  "人",
  "先生",
  "僧侶",
  "菩薩",
]

scoreForAward = [
  1,
  2,
  10,
  20,
  30,
]

awardTitle = ->
  award = null
  for num, idx in scoreForAward
    if num > score.num
      break
    award = awards[idx]
  return award

gameover = ->
  gameIsOver = true
  new EndScreen()
  return

setGamePos = (x, y) ->
  game.rootScene.x = x
  game.rootScene.y = y
  score.x = - x + 10
  score.y = - y + 10


window.onload = ->
  game = enchant.Core(GAME_WIDTH, GAME_HEIGHT)
  game.fps = 30
  game.preload(tokuImage)
  game.preload(titleImage)

  game.onload = ->
    world = new PhysicsWorld(0.0, 25)
    floor = new Floor()
    score = new Score()
    new Title()

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
      # toku.checkPos()
      toku = null
      score.gain()
      setTimeout ->
        toku = new Toku
      , 500

    game.rootScene.onenterframe = (e) ->
      world.step(game.fps)

  game.start()
