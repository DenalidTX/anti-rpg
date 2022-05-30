extends Node

# This differentiates movement from other actions.
enum EnemyMode {
    Normal = 0,
    Falling = 1, #Fallingintoa pit.
    Looting = 2, # Going for a placeable loot item.
    Returning = 3, # Going back to town.
    Disabled = 999
}

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
            
            if enemy.current_mode == EnemyMode.Looting || enemy.current_mode == EnemyMode.Returning:
                # If the enemy already has a loot target, don't interrupt him.
                pass
            else:
                enemy.enable_collision()
                
                var dist_a1 = -1
                var node_a1 = get_parent().get_node("AntlerPile1Node")
                if node_a1.visible == true:
                    dist_a1 = node_a1.position.distance_to(enemy.position)
                    
                var dist_a2 = -1
                var node_a2 = get_parent().get_node("AntlerPile2Node")
                if node_a2.visible == true:
                    dist_a2 = node_a2.position.distance_to(enemy.position)
                    
                # If the enemy is within range of a "treasure", go for that.
                if dist_a1 > 0 and dist_a1 < 200:
                    var new_path = enemy_nav.get_simple_path(enemy.position, node_a1.position)
                    enemy.set_next_path_target(node_a1.position, new_path)
                    
                if dist_a2 > 0 and dist_a2 < 200:
                    var new_path = enemy_nav.get_simple_path(enemy.position, node_a2.position)
                    enemy.set_next_path_target(node_a2.position, new_path)
                    
                # Otherwise, if the enemy doesn't already have a path, provide one.
                elif path_graph_root != null and enemy.needs_path():
                    var last_path_target = enemy.last_path_target
                    if last_path_target == null:
                        enemy.set_position(path_graph_root.position)
                        enemy.disable_collision()
                        last_path_target = path_graph_root
                        
                    var pathing_targets = last_path_target.children
                    if pathing_targets.size() == 0:
                        # TODO: Deactivate
                        # For now, reset.
                        enemy.last_path_target = null
                    else:
                        var next_point = rng.randi_range(0, pathing_targets.size() * 2)
                        if next_point < pathing_targets.size():
                            var new_path = enemy_nav.get_simple_path(enemy.position, pathing_targets[next_point].position)
                            enemy.set_next_path_target(pathing_targets[next_point], new_path, true)
                        else:
                            enemy.animate_think() # There's a chance we'll just idle.
