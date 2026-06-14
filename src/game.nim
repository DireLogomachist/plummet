import intsets, tables, sugar
from dom import document, getElementById, ImageElement, Event, window, requestAnimationFrame
from std/paths import Path, extractFilename
import std/times, std/strformat
import jscanvas except Path

import assets
from draw import Drawable, SpriteDrawable, draw, newImageElement
from gameobj import GameObject, update, draw, checkCollisions, addCollider
import enemy
import player
import level
from utils import normalize


type
    Game* = ref object
        keyboard*: IntSet
        assetCounter: int
        player*: Player
        gameObjectCounter*: int = 0
        gameObjectList*: seq[GameObject]
        collisionMap*: Table[int, int]
        canvas*: CanvasElement
        canvasContext*: CanvasContext
        canvasColor* = cstring("#7b8210")
        canvasWidth* = 512
        deltaTime*: float = 0.0
        lastUpdate*: Time
        levelTimer*: float = 0.0
        nextSpawnIdx*: int = 0
        currentLevel*: seq[SpawnEvent]

    Key* {.pure.} = enum
        LeftArrow = 37, UpArrow = 38,
        RightArrow = 39, DownArrow = 40

proc registerGameObject*(self: Game, gameObject: GameObject) =
    self.gameObjectCounter = self.gameObjectCounter + 1
    gameObject.id = self.gameObjectCounter
    self.gameObjectList.add(gameObject)

proc newGame*(): Game =
    let canvas = document.getElementById("gameCanvas").CanvasElement
    let ctx = canvas.getContext2d()
    ctx.font = "8px monospace"
    var player = newPlayer()
    var game = Game(player: player, canvas: canvas, canvasContext: ctx, lastUpdate: getTime(), currentLevel: Level1)
    return game

proc GameInstance*(): Game =
    var game {.global.}: Game
    if isNil(game):
        game = newGame()
        return game
    else:
        return game

proc spawnEnemy(self: Game, spawnEvent: SpawnEvent) =
    case spawnEvent.enemyType
    of DiverSpawn:
        var e = newDiver(spawnEvent.x, spawnEvent.y)
        self.registerGameObject(e)
    of ExploderSpawn:
        var e = newExploder(spawnEvent.x, spawnEvent.y, spawnEvent.targetX, spawnEvent.targetY)
        self.registerGameObject(e)
    of GridBombSpawn:
        var e = newGridBomb(spawnEvent.x, spawnEvent.y)
        self.registerGameObject(e)

proc updateLevelSpawns(self: Game) =
    while self.nextSpawnIdx < self.currentLevel.len and 
          self.levelTimer >= self.currentLevel[self.nextSpawnIdx].triggerTime:
        self.spawnEnemy(self.currentLevel[self.nextSpawnIdx])
        self.nextSpawnIdx += 1

proc processInputs(self: Game) = 
    # Player movement
    var xMove = 0
    var yMove = 0

    # Check keys against keyboard state
    if ord(Key.LeftArrow) in self.keyboard:
        xMove = -1
    if ord(Key.RightArrow) in self.keyboard:
        xMove = 1
    if ord(Key.UpArrow) in self.keyboard:
        yMove = -1
    if ord(Key.DownArrow) in self.keyboard:
        yMove = 1

    # Move player
    var direction: (float, float) = normalize(xMove, yMove)
    if direction[0] != 0:
        self.player.loc.x += self.player.speed * self.deltaTime * direction[0]
    if direction[1] != 0:
        self.player.loc.y += self.player.speed * self.deltaTime * direction[1]

proc drawAll(self: Game) = 
    # Draw background
    self.canvasContext.fillStyle = self.canvasColor
    self.canvasContext.fillRect(0, 0, self.canvasWidth, self.canvasWidth)

    # Draw game objects
    for gameObject in self.gameObjectList:
        gameObject.draw(self.canvasContext)

    # Draw player
    self.player.draw(self.canvasContext)

proc drawMetrics(self: Game) = 
    self.canvasContext.fillStyle = "#294139"
    self.canvasContext.fillText(fmt"FPS: {int(1000/self.deltatime)}", 0, 10)

proc update*(self: Game) = 
    # Calculate deltatime
    var currentTime = getTime()
    self.deltaTime = float(inMilliseconds(currentTime - self.lastUpdate))
    self.lastUpdate = currentTime

    # Update level timer
    self.levelTimer += self.deltaTime / 1000.0

    # Check level spawns
    self.updateLevelSpawns()

    # Check collisions of player against all objects
    self.collisionMap.clear()
    for gameObject in self.gameObjectList:
        if self.player.checkCollisions(gameObject):
            self.collisionMap[gameObject.id] = 0

    # Check for key presses, player updating
    self.processInputs()

    # Update player
    self.player.update(self.deltaTime)

    # Game object updates
    var deleteList: seq[int]
    for i in countup(0, self.gameObjectList.len - 1):
        self.gameObjectList[i].update(self.deltaTime)
        if self.gameObjectList[i].dead:
            deleteList.add(i)
    
    # Remove dead objects
    for i in countup(0, deleteList.len - 1):
        self.gameObjectList.delete(deleteList[i] - i)

    # Draw scene
    self.drawAll()

    # Draw Metrics
    self.drawMetrics()

proc tick(self: Game, time: float) =
    # Schedule next tick
    discard window.requestAnimationFrame((time: float) => tick(self, time))

    # Update game state
    self.update()

proc assetReady(self: Game, asset: string, image: ImageElement, e: Event) =
    self.assetCounter += 1
    assetCache[string(extractFilename(Path(asset)))] = image
    echo fmt"Loaded {asset} - stored as {string(extractFilename(Path(asset)))}"

    # Once all loaded, start game tick
    if len(assetList) == self.assetCounter:
        self.tick(16)

proc loadAssetsAndStart*(self: Game) = 
    for i in countup(0, assetList.len - 1):
        capture i:
            echo fmt"Loading {i} -  {assetList[i]}"
            var assetFile = assetList[i]
            var assetImage: ImageElement = newImageElement()
            assetImage.onload = (event: Event) => self.assetReady(assetFile, assetImage, event)
            assetImage.src = cstring(assetFile)
