extends KinematicBody2D

var path = null
var speed = 100

var last_move = null

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    
    # Credit: The pathfinding logic was copied from:
    #   https://www.davidepesce.com/2019/11/19/godot-tutorial-how-to-use-navigation2d-for-pathfinding/
    # Calculate the movement distance for this frame
    var distance_to_walk = speed * delta
    
    # Move the player along the path until he has run out of movement or the path ends.
    if path != null and distance_to_walk > 0 and path.size() > 0:
        var move_done = false
        # Get this first so that we can play the right animation.
        var distance_to_next_point = position.distance_to(path[0])
        
        if distance_to_next_point > 0:
            # Update animation direction.
            if position.x < path[0].x:
                $EnemySprite.play("Walk Right")
            else:
                $EnemySprite.play("Walk Left")
            # Also update size b/c the sprite sheets don't match.
            $EnemySprite.scale.x = 0.5
            $EnemySprite.scale.y = 0.5
        else:
            $EnemySprite.play("Idle")
            $EnemySprite.scale.x = 0.5 * 0.75
            $EnemySprite.scale.y = 0.5 * 0.75
        
        var direction = position.direction_to(path[0])
        var velocity = direction * distance_to_walk
        if distance_to_walk >= distance_to_next_point:
            # The player get to the next point
            velocity = direction * distance_to_next_point
            path.remove(0)
            move_done = true
        else:
            velocity = direction * speed
            
        # Using movee_and_collide causes enemies to get stuck badly.
        # This lets them unstick.
        
        var old_position = position
        move_and_slide(velocity)
        var new_position = position
        last_move = new_position - old_position
        
        
        # Try to unstick if possible.
        if !move_done \
            and abs(last_move.x) < abs(velocity.x * delta / 2.0) \
            and abs(last_move.y) < abs(velocity.y * delta / 2.0):
                var move_to_try = rng.randi_range(0, 3)
                if move_to_try == 0:
                    move_and_slide(Vector2(-direction.x, -direction.y) * speed)
                elif move_to_try == 1:
                    move_and_slide(Vector2(0, direction.y) * speed * 25.0)
                elif move_to_try == 2:
                    move_and_slide(Vector2(direction.x, 0) * speed * 25.0)
    else:
        $EnemySprite.play("Idle")
        $EnemySprite.scale.x = 0.5 * 0.75
        $EnemySprite.scale.y = 0.5 * 0.75

func get_position():
    return $EnemySprite.position

func set_path(new_path: Array):
    self.path = [] + new_path
    
func needs_path():
    return path == null || path.size() == 0
