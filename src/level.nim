type
  EnemySpawnType* = enum
    DiverSpawn, ExploderSpawn, GridBombSpawn
  
  SpawnEvent* = object
    triggerTime*: float      # Seconds into level
    enemyType*: EnemySpawnType
    x*, y*: float
    targetX*, targetY*: float = 0.0   # For Exploder

  Level* = object
    name*: string
    spawns*: seq[SpawnEvent]

# Level definitions
const Level1*: seq[SpawnEvent] = @[
  SpawnEvent(triggerTime: 1.0, enemyType: GridBombSpawn, x: 19.5, y: 19.5),
  SpawnEvent(triggerTime: 1.5, enemyType: GridBombSpawn, x: 19.5, y: 58.5),
  SpawnEvent(triggerTime: 2.0, enemyType: GridBombSpawn, x: 19.5, y: 97.5),
  SpawnEvent(triggerTime: 2.5, enemyType: GridBombSpawn, x: 19.5, y: 136.5),

  SpawnEvent(triggerTime: 3.0, enemyType: GridBombSpawn, x: 58.5, y: 19.5),
  SpawnEvent(triggerTime: 3.5, enemyType: GridBombSpawn, x: 58.5, y: 58.5),
  SpawnEvent(triggerTime: 4.0, enemyType: GridBombSpawn, x: 58.5, y: 97.5),
  SpawnEvent(triggerTime: 4.5, enemyType: GridBombSpawn, x: 58.5, y: 136.5),

  SpawnEvent(triggerTime: 5.0, enemyType: GridBombSpawn, x: 97.5, y: 19.5),
  SpawnEvent(triggerTime: 5.5, enemyType: GridBombSpawn, x: 97.5, y: 58.5),
  SpawnEvent(triggerTime: 6.0, enemyType: GridBombSpawn, x: 97.5, y: 97.5),
  SpawnEvent(triggerTime: 6.5, enemyType: GridBombSpawn, x: 97.5, y: 136.5),

  SpawnEvent(triggerTime: 7.0, enemyType: GridBombSpawn, x: 136.5, y: 19.5),
  SpawnEvent(triggerTime: 7.5, enemyType: GridBombSpawn, x: 136.5, y: 58.5),
  SpawnEvent(triggerTime: 8.0, enemyType: GridBombSpawn, x: 136.5, y: 97.5),
  SpawnEvent(triggerTime: 8.5, enemyType: GridBombSpawn, x: 136.5, y: 136.5)
]
