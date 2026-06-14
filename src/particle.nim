import jscanvas except Path
from math import round
import random

from draw import Drawable
import gameobj
import transform


type
    ParticleSystem* = ref object of GameObject
        particles*: seq[Particle]
        spawnRate*: float = 100             # Per second
        particleVelocity*: float = 0.2
        particleLifetime*: float = 1.0      # Seconds
        timeSinceLastSpawn: float = 0.0     # Seconds
        particleFreeBuffer: seq[int]

    Particle* = ref object of Drawable
        lifetime*: float = 0.0              # Seconds
        velocity*: float = 0.0 

    StreamParticleSystem* = ref object of ParticleSystem
        spawnDirection*: float = 0.0
        spawnSpread*: float = 0.0

    LineParticleSystem* = ref object of ParticleSystem
        lineLength*: float = 156.0
        isHorizontal*: bool = true

method draw*(self: Particle, context: CanvasContext) = 
    var global = self.getGlobalLocation()
    context.fillStyle = self.color
    context.fillRect(round(global.x - self.size.w/2), round(global.y - self.size.h/2),
                     self.size.w, self.size.h)

method update*(self: Particle, deltatime: float) = 
    if self.enabled:
        self.loc.x += self.velocity * deltatime * self.rot.getVector().x
        self.loc.y += self.velocity * deltatime * self.rot.getVector().y
        self.lifetime  = self.lifetime + deltatime/1000

method spawn*(self: ParticleSystem) = 
    if not self.enabled:
        return
    if self.particleFreeBuffer.len > 0:
        var newParticle = self.particles[self.particleFreeBuffer.pop()]
        newParticle.enabled = true
        newParticle.lifetime = 0.0
        newParticle.loc = self.getGlobalLocation()
        newParticle.velocity = self.particleVelocity
    else:
        var newParticle = Particle()
        newParticle.size = (w: 1, h: 1)
        newParticle.loc = self.getGlobalLocation()
        newParticle.velocity = self.particleVelocity
        self.particles.add(newParticle)

    # Set direction / velocity based on limits

method draw*(self: ParticleSystem, context: CanvasContext) = 
    for particle in self.particles:
        particle.draw(context)

method update*(self: ParticleSystem, deltatime: float) = 
    self.timeSinceLastSpawn = self.timeSinceLastSpawn + deltatime
    if self.timeSinceLastSpawn > 1000.0/self.spawnRate:
        self.spawn()
        self.timeSinceLastSpawn = 0.0

    for i, particle in self.particles:
        particle.update(deltatime)
        if particle.lifetime > self.particleLifetime:
            particle.enabled = false
            self.particleFreeBuffer.add(i)

method spawn*(self: LineParticleSystem) =
    if not self.enabled:
        return
    
    var randomOffset = random.rand(0.0 .. self.lineLength)
    
    if self.particleFreeBuffer.len > 0:
        var newParticle = self.particles[self.particleFreeBuffer.pop()]
        newParticle.enabled = true
        newParticle.lifetime = 0.0
        var spawnLoc = self.getGlobalLocation()
        if self.isHorizontal:
            spawnLoc.x += randomOffset
        else:
            spawnLoc.y += randomOffset
        newParticle.loc = spawnLoc
        newParticle.velocity = self.particleVelocity
    else:
        var newParticle = Particle()
        newParticle.size = (w: 1, h: 1)
        var spawnLoc = self.getGlobalLocation()
        if self.isHorizontal:
            spawnLoc.x += randomOffset
        else:
            spawnLoc.y += randomOffset
        newParticle.loc = spawnLoc
        newParticle.velocity = self.particleVelocity
        self.particles.add(newParticle)
