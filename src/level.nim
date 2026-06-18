type
    EnemySpawnType* = enum
        DiverSpawn, ExploderSpawn, GridBombSpawn, FloaterSpawn
  
    LevelEvent* = ref object of RootObj
        time*: float     # Wait in seconds from last event
    
    WaitEvent* = ref object of LevelEvent

    SpawnEvent* = ref object of LevelEvent
        enemyType*: EnemySpawnType
        x*, y*: float
        targetX*, targetY*: float = 0.0   # For Exploder


const originY: float = 148;

# Level definitions
let Level1*: seq[LevelEvent] = @[
    WaitEvent(time:1.0),
    SpawnEvent(time: 0.5, enemyType: DiverSpawn, x: 78, y: originY),

    SpawnEvent(time: 1.5, enemyType: ExploderSpawn, x: 52, y: originY, targetX: 52, targetY: 78),
    SpawnEvent(time: 0.0, enemyType: ExploderSpawn, x: 104, y: originY, targetX: 104, targetY: 78),

    SpawnEvent(time: 1.5, enemyType: DiverSpawn, x: 104, y: originY),
    SpawnEvent(time: 0.5, enemyType: DiverSpawn, x: 72, y: originY),
    SpawnEvent(time: 0.5, enemyType: DiverSpawn, x: 300, y: originY),

    SpawnEvent(time: 0.5, enemyType: ExploderSpawn, x: 200, y: originY, targetX: 256, targetY: 0)
]
