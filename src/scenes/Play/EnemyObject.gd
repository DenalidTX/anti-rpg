extends Node

var sprite_scene = null
var current_path = null

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
    
func setup(my_sprite):
    sprite_scene = my_sprite

func get_position():
    return sprite_scene.position
