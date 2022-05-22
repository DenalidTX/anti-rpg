extends Node

var update_delay = 50

var rng = RandomNumberGenerator.new()

var enemies = []
var enemy_nav : Navigation2D = null
var path_graph_root = null

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func initialize(enemies, enemy_nav, path_root):
    self.enemies = enemies
    self.enemy_nav = enemy_nav
    self.path_graph_root = path_root

func update_paths():
    update_delay -= 1
    if update_delay <= 0:
        update_delay = 100
    
        for enemy in enemies:
            if path_graph_root != null and enemy.needs_path():
                var last_path_target = enemy.last_path_target
                if last_path_target == null:
                    enemy.set_position(path_graph_root.position)
                    last_path_target = path_graph_root
                    
                var pathing_targets = last_path_target.children
                if pathing_targets.size() == 0:
                    # TODO: Deactivate
                    pass
                else:
                    var next_point = rng.randi_range(0, pathing_targets.size()+5)
                    if next_point < pathing_targets.size():
                        var new_path = enemy_nav.get_simple_path(enemy.position, pathing_targets[next_point].position)
                        enemy.set_next_path_target(pathing_targets[next_point], new_path)
                    else:
                        enemy.animate_idle() # There's a chance we'll just idle.
