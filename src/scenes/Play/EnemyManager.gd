extends Node

var update_delay = 50

var rng = RandomNumberGenerator.new()

var enemies = []
var enemy_nav : Navigation2D = null
var pathing_targets = []

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func initialize(enemies, enemy_nav, pathing_targets):
    self.enemies = enemies
    self.enemy_nav = enemy_nav
    self.pathing_targets = pathing_targets

func update_paths():
    update_delay -= 1
    if update_delay <= 0:
        update_delay = 100
    
        for enemy in enemies:
            if not pathing_targets.empty() and enemy.needs_path():
                var next_point = rng.randi_range(0, pathing_targets.size()+2)
                var path = [] # There's a chance we'll just idle.
                if next_point < pathing_targets.size():
                    path = enemy_nav.get_simple_path(enemy.position, pathing_targets[next_point])
                enemy.set_path(path)
