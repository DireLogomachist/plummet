import tables
from dom import ImageElement


var assetCache*: Table[string, ImageElement]

var assetList*: seq[string] = @[
    "src/assets/plummet_player.png",
    "src/assets/player_exhaust.png",
    "src/assets/player_exhaust_slow.png",
    "src/assets/player_exhaust_fast.png",
    "src/assets/diver.png",
    "src/assets/exploder.png",
    "src/assets/floater.png",
    "src/assets/gridbomb.png",
]
