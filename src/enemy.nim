import gameobj
import draw
import collision
import math

## Base Enemy

type
    Enemy* = ref object of GameObject
        health*: int = 1

proc newEnemy*(x: float, y: float): Enemy =
    var newEnemy = Enemy()
    newEnemy.loc = (x: x, y: y)
    newEnemy.sprite = Drawable(loc: (x: 0, y: 0), size: (w: 20, h: 20))
    newEnemy.sprite.parent = newEnemy

    var col: ColliderBox = ColliderBox(size: (w: 20, h: 20))
    newEnemy.addCollider(col)
    return newEnemy

method onCollide*(self: Enemy) = 
    if not self.onCollisionCooldown:
        self.collisionTimer = self.collisionCooldown
        self.onCollisionCooldown = true
        self.health -= 1

method destroy*(self: Enemy) = 
    self.enabled = false
    self.dead = true
    self.parent = nil

method die*(self: Enemy) = 
    for collider in self.colliders:
        collider.enabled = false
    self.sprite.enabled = false
    # after wait, disable and destroy
    self.destroy()

method update*(self: Enemy, deltatime: float) =
    procCall self.GameObject.update(deltatime)

    if self.health <= 0:
        self.die()

## Diver

type
    Diver* = ref object of Enemy
        speed*: float = - 0.2

proc newDiver*(x: float, y: float): Diver =
    var d = Diver()
    d.loc = (x: x, y: y)
    d.sprite = SpriteDrawable(size: (w: 16, h: 16), spriteFile: "diver.png")
    d.sprite.parent = d
    
    var col: ColliderBox = ColliderBox(size: (w: 10, h: 10))
    d.addCollider(col)

    return d

method update*(self: Diver, deltatime: float) =
    procCall self.GameObject.update(deltatime)

    # Wait 1 second, then dive
    if self.lifeTimer > 1.0:
        self.loc.y += self.speed * deltatime

    if self.loc.y < 0.0:
        self.die()

    if self.health <= 0:
        self.die()

## Exploder

type
    Exploder* = ref object of Enemy
        speed*: float = 0.08
        targetPos*: (float, float)
        reachedTarget*: bool = false
        detonationTimer*: float = 0.0
        detonationDuration*: float = 0.5
        isDetonating*: bool = false

proc newExploder*(x: float, y: float, targetX: float, targetY: float): Exploder =
    var e = Exploder()
    e.loc = (x: x, y: y)
    e.targetPos = (x: targetX, y: targetY)
    e.sprite = SpriteDrawable(size: (w: 16, h: 16), spriteFile: "exploder.png")
    e.sprite.parent = e
    
    var col: ColliderBox = ColliderBox(size: (w: 10, h: 10))
    col.drawOutline = true
    e.addCollider(col)

    return e

method update*(self: Exploder, deltatime: float) =
    procCall self.GameObject.update(deltatime)

    if not self.isDetonating:
        # Approach target position
        if not self.reachedTarget:
            if self.lifeTimer > 1.0:
                let dx = self.targetPos[0] - self.loc.x
                let dy = self.targetPos[1] - self.loc.y
                let dist = math.sqrt(dx * dx + dy * dy)
                
                if dist > 2.0:
                    let dirX = dx / dist
                    let dirY = dy / dist
                    self.loc.x += dirX * self.speed * deltatime
                    self.loc.y += dirY * self.speed * deltatime
                else:
                    self.reachedTarget = true
        
        # Wait at target, then detonate
        if self.reachedTarget and self.lifeTimer > 1.0:
            self.isDetonating = true
            self.detonationTimer = 0.0
            # Swap to large explosion collider
            self.colliders.setLen(0)
            var explosionCol: ColliderBox = ColliderBox(size: (w: 40, h: 40))
            explosionCol.drawOutline = true
            self.addCollider(explosionCol)
    else:
        # Detonation active—count down
        self.detonationTimer += deltatime / 1000.0
        if self.detonationTimer > self.detonationDuration:
            self.die()

    if self.health <= 0:
        self.die()

## GridBomb

type
    GridBomb* = ref object of Enemy
        detonationTimer*: float = 2.0
        detonationDuration*: float = 0.5

proc newGridBomb*(x: float, y: float): GridBomb =
    var g = GridBomb()
    g.loc = (x: x, y: y)
    g.sprite = SpriteDrawable(size: (w: 39, h: 39), spriteFile: "gridbomb.png")
    g.sprite.parent = g

    var col: ColliderBox = ColliderBox(size: (w: 39, h: 39))
    col.enabled = false
    col.drawOutline = true
    g.addCollider(col)

    return g

method update*(self: GridBomb, deltatime: float) =
    procCall self.GameObject.update(deltatime)

    # Countdown
    if self.detonationTimer > 0.0:
        self.detonationTimer -= deltatime / 1000.0
        if self.detonationTimer < 0.0:
            self.sprite.enabled = false
            for collider in self.colliders:
                collider.enabled = true
    else:
        self.detonationDuration -= deltatime / 1000.0
        if self.detonationDuration < 0.0:
            self.die()
