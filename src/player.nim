import tables
from dom import ImageElement
import jscanvas except Path
import math

import assets
import gameobj
from collision import ColliderBox, ColliderCircle, draw
from draw import Drawable, SpriteDrawable, load, draw
from particle import ParticleSystem, StreamParticleSystem, update, draw
import transform


type
    ExhaustType* = enum
        Default, Boosting, Slowing

    ExhaustState* = ref object
        state: ExhaustType
        changed: bool = false

    PlayerExhaust* = ref object of GameObject
        flickerRate*: float = 100.0
        state*: ExhaustState = ExhaustState(state: ExhaustType.Default)

    Player* = ref object of GameObject
        health*: int = 3
        speed*: float = 0.2
        trail*: PlayerExhaust

## ExhaustState

method get*(self: ExhaustState): ExhaustType =
    return self.state

method set*(self: ExhaustState, value: ExhaustType) {.base.} = 
    self.state = value
    self.changed = true

method isChanged(self: ExhaustState): bool {.base.} =
    let value = self.changed
    self.changed = false
    return value

## Player Exhaust

proc newPlayerExhaust*(): PlayerExhaust = 
    var exhaust = PlayerExhaust()
    exhaust.sprite = SpriteDrawable(size: (w: 16, h: 16), spriteFile: "player_exhaust.png")
    exhaust.sprite.parent = exhaust
    return exhaust

method update*(self: PlayerExhaust, deltatime: float) = 
    procCall self.GameObject.update(deltatime)

    var flickerFlag = math.sin(self.lifeTimer * self.flickerRate)
    if self.sprite.enabled == false and flickerFlag > 0:
        self.sprite.enabled = true
    elif self.sprite.enabled == true and flickerFlag <= 0:
        self.sprite.enabled = false

## Player

method die(self: Player) = 
    self.trail.enabled = false
    echo "Played died"

method onCollide*(self: Player) = 
    if not self.onCollisionCooldown:
        self.collisionTimer = self.collisionCooldown
        self.onCollisionCooldown = true
        self.health -= 1

proc newPlayer*(): Player = 
    var player = Player()
    player.id = 0
    player.loc.x = 78
    player.loc.y = 28
    player.sprite = SpriteDrawable()
    player.sprite.parent = player
    player.trail = newPlayerExhaust()
    player.trail.parent = player
    player.trail.loc.y = -16.0
    
    var col: ColliderCircle = ColliderCircle(radius: 9)
    #col.drawOutline = true
    player.addCollider(col)
    return player

method draw*(self: Player, context: CanvasContext) = 
    if self.sprite.loaded != true:
        self.sprite.load()
    self.sprite.draw(context)

    self.trail.draw(context)

    for collider in self.colliders:
        if collider.drawOutline:
            collider.draw(context)

method update*(self: Player, deltatime: float) = 
    procCall self.GameObject.update(deltatime)

    self.trail.update(deltatime)
    if self.trail.enabled:
        if self.trail.state.isChanged():
            if self.trail.state.get() == ExhaustType.Boosting:
                SpriteDrawable(self.trail.sprite).spriteImage = assetCache["player_exhaust_fast.png"]
            elif self.trail.state.get() == ExhaustType.Slowing:
                SpriteDrawable(self.trail.sprite).spriteImage = assetCache["player_exhaust_slow.png"]
            else:
                SpriteDrawable(self.trail.sprite).spriteImage = assetCache["player_exhaust.png"]

    if self.health <= 0:
        self.die()
