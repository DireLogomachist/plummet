import jscanvas except Path

import gameobj
import draw
import math

## Bomber

type
    Bomber* = ref object of GameObject
        rockSpeed: float = 1.0
        rockDist: float = 0.12
        propFlickerRate*: float = 100.0
        
        propeller: Drawable

proc newBomber*(x: float, y: float): Bomber =
    var bomber = Bomber(loc: (x, y))
    bomber.sprite = SpriteDrawable(size: (w: 156, h: 78), spriteFile: "bomber.png")
    bomber.sprite.parent = bomber
    #bomber.sprite.enabled = false
    bomber.propeller = Drawable(loc:(71, -3), size:(1, 22))
    bomber.propeller.parent = bomber
    return bomber

method update*(self: Bomber, deltatime: float) =
    procCall self.GameObject.update(deltatime)

    self.loc.y += self.rockDist * (math.sin(self.rockSpeed * self.lifeTimer) / (2*math.PI))

    var propFlicker = math.sin(self.lifeTimer * self.propFlickerRate)
    if self.propeller.enabled == false and propFlicker > 0:
        self.propeller.enabled = true
    elif self.propeller.enabled == true and propFlicker <= 0:
        self.propeller.enabled = false

method draw*(self: Bomber, context: CanvasContext) = 
    procCall self.GameObject.draw(context)
    self.propeller.draw(context)
