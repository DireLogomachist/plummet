import jscanvas except Path

import transform
import draw
import collision


type
    GameObject* = ref object of TransformObject
        id*: int
        sprite*: Drawable
        enabled*: bool = true
        dead*: bool = false
        lifeTimer*: float = 0.0

        colliders*: seq[Collider]
        onCollisionCooldown*: bool = false
        collisionCooldown*: float = 0.5
        collisionTimer*: float = 0.0

method onCollide*(self: GameObject) {.base.} = 
    discard

proc updateCollisionTimer*(self: GameObject, deltatime: float) = 
    if self.onCollisionCooldown:
        self.collisionTimer -= deltatime/1000
        if self.collisionTimer < 0.0:
            self.collisionTimer = 0.0
            self.onCollisionCooldown = false

proc addCollider*(self: GameObject, collider: Collider) = 
    collider.parent = self
    self.colliders.add(collider)

proc checkCollisions*(self: GameObject, target: GameObject): bool =
    for collider in self.colliders:
        for targetCollider in target.colliders:
            if collider.collisionCheck(targetCollider):
                target.onCollide()
                self.onCollide()
                return true
    return false

method update*(self: GameObject, deltatime: float) {.base.} = 
    self.lifeTimer = self.lifeTimer + deltatime/1000
    self.updateCollisionTimer(deltatime)

method draw*(self: GameObject, context: CanvasContext) {.base.} = 
    if self.sprite != nil:
        if self.sprite.loaded != true:
            self.sprite.load()

        self.sprite.draw(context)

    for collider in self.colliders:
        if collider.drawOutline:
            collider.draw(context)