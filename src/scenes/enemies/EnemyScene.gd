extends KinematicBody2D

# Movement speed. This is up here so that it's easily identified and adjusted.
var speed = 100

# This differentiates movement from other actions.
enum EnemyMode {
    Normal = 0,
    Falling = 1, #Fallingintoa pit.
    Looting = 2, # Going for a placeable loot item.
    Returning = 3, # Going back to town.
    Disabled = 999
}
var current_mode = EnemyMode.Normal

var fall_position = null
var fall_size_adjust = 1
var fall_pause = 0

# This is the current path, if any. Unfortunately that means
# that the enemy holds state from frame to frame instead of
# having a separate game state. Probably should change that.
var path = null

# This prevents us "walking" to where we already are.
var last_path_target = null
var last_path_position = null

# This is used to work around obstacles.
var bouncing = 0
var bounce_velocity = null

var rng = RandomNumberGenerator.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
    if current_mode == EnemyMode.Normal:
        do_move(delta)
    elif current_mode == EnemyMode.Falling:
        animate_fall()
        if position != fall_position:
            var direction = position.direction_to(fall_position)
            var new_velocity = direction

            var distance = position.distance_to(fall_position)
            if distance < 1:
                new_velocity *= distance
            fall_size_adjust *= 0.95
            move_and_collide(new_velocity)
        elif fall_pause < 10:
            fall_pause += 1
        elif fall_size_adjust > 0.2:
            fall_size_adjust *= 0.95
        else:
            # TODO: Add score or something.
            current_mode = EnemyMode.Disabled
            find_parent("MainScene").get_node("Enemies").remove_child(self)

func do_move(delta):
    
    # Credit: I started with the below tutorial, but by the time I was done
    # the logic was completely different because collision avoidance doesn't
    # really work with the pathfinding system. XD
    #   https://www.davidepesce.com/2019/11/19/godot-tutorial-how-to-use-navigation2d-for-pathfinding/
    
    # Calculate the movement distance for this frame
    var distance_to_walk = speed * delta
    
    # Move the player along the path until he has run out of movement or the path ends.
    if path != null and distance_to_walk > 0 and path.size() > 0:
        if bounce_velocity != null and bouncing > 0:
            move_and_slide(bounce_velocity)
            bouncing -= 1
            
        else:
            var move_done = false
            # Get this first so that we can play the right animation.
            var distance_to_next_point = position.distance_to(path[0])
            
            if distance_to_next_point > 0:
                # Update animation direction.
                if position.x < path[0].x: animate_right()
                else: animate_left()
            
            var direction = position.direction_to(path[0])
            var velocity = direction * distance_to_walk
            if distance_to_walk >= distance_to_next_point:
                # The player reaches the next point
                velocity = direction * distance_to_next_point
                path.remove(0)
                move_done = true
                animate_idle()
            else:
                velocity = direction * speed
                
            # Using move_and_collide causes enemies to get stuck badly.
            # This lets them unstick.
            
            var old_position = position
            move_and_slide(velocity)
            var new_position = position
            var last_move = new_position - old_position
            
            var collision : KinematicCollision2D
            collision = get_last_slide_collision()
            
            if collision != null:
                # print("Collided with: " + collision.collider.name)
                if collision.collider.name == "PitCollisionBody":
                    collision.collider.get_node("PitAvoidanceShape").set_deferred("disabled", false)
                    collision.collider.get_parent().get_node("PitCoverNode").set_deferred("visible", false)
                    current_mode = EnemyMode.Falling
                    fall_position = collision.collider.get_parent().position
                    # Importantly, this is the -enemy- collision area, not anything on the map.
                    get_node("CollisionArea").set_deferred("disabled", true)
                    fall_size_adjust = 1
                    fall_pause = 0
                else:
                    bounce_velocity = velocity.bounce(collision.normal)
                    move_and_slide(bounce_velocity)
                    bouncing = 10

func get_position():
    return position

func set_position(new_position : Vector2):
    position = new_position
    
func set_next_path_target(next_path_target, new_path):
    last_path_target = next_path_target
    set_path(new_path)

func set_path(new_path: Array):
    var path_set = false
    if new_path != null and new_path.size() > 0:
        var new_path_target = new_path[new_path.size() - 1]
        if new_path_target != last_path_position:
            path = [] + new_path
            last_path_position = new_path_target
            path_set = true
    if !path_set:
        animate_think()
    
func needs_path():
    return path == null || path.size() == 0

# All of these animage functions rescale the sprite. This is
# due to the fact that the sprite sheets themselves are scaled
# differently (48 and 64 pixels), and the full size is larger
# than I want, anyhow.
func animate_right():
    $EnemySprite.play("Walk Right")
    # Also update size b/c the sprite sheets don't match.
    scale.x = 0.5
    scale.y = 0.5

func animate_left():
    $EnemySprite.play("Walk Left")
    # Also update size b/c the sprite sheets don't match.
    scale.x = 0.5
    scale.y = 0.5

func animate_idle():
    $EnemySprite.play("Idle")
    scale.x = 0.5 * 0.75
    scale.y = 0.5 * 0.75

func animate_think():
    $EnemySprite.play("Thinking")
    scale.x = 0.5 * 0.75
    scale.y = 0.5 * 0.75

func animate_fall():
    $EnemySprite.play("Fall")
    scale.x = 0.5 * 0.75 * fall_size_adjust
    scale.y = 0.5 * 0.75 * fall_size_adjust
