extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass

func get_enemy_path_nav():
    return $EnemyPathNavigation

func get_enemy_treasure_nav():
    return $EnemyTreasureNavigation

func get_full_nav():
    return $FullNav
