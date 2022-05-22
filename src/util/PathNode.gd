extends Object

# This class is a node within a tree that forms paths for the enemies.
# Internal nodes are decision nodes; the enemy will either choose a
# child node or a nearby treasure (if any are close enough). Once an
# enemy reaches a leaf node, that enemy will leave the map. The player
# attempts to prevent the enemies from reaching the forest (any leaf
# node).
class_name PathNodeType

# Array of child PathNode objects
var children : Array = []
var position = null

func _init(my_position):
    self.position = my_position
