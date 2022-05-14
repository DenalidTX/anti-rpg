extends Area2D

export var speed = 200 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var idle_time = 0 # Time since last movement/animation.
var idle_animation_check = 100 # Time to wait before maybe animating "bored"

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	
	# Check for movement keys.
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
		if Input.is_action_just_pressed("move_left"):
			$PlayerSprite.play("Walk Left")
			$PlayerSprite.flip_h = false
	if Input.is_action_pressed("move_right"):
		if Input.is_action_just_pressed("move_right"):
			$PlayerSprite.play("Walk Left")
			$PlayerSprite.flip_h = true
		velocity.x += 1
	if Input.is_action_pressed("move_up"):
		if Input.is_action_just_pressed("move_up"):
			$PlayerSprite.play("Walk Left")
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		if Input.is_action_just_pressed("move_down"):
			$PlayerSprite.play("Walk Left")
		velocity.y += 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
		position += velocity * delta
		position.x = clamp(position.x, 0, screen_size.x)
		position.y = clamp(position.y, 0, screen_size.y)
	
		idle_time = 0
	else:
		idle_time += 1
		
	if idle_time == idle_animation_check:
		$PlayerSprite.play("Bored")
	if idle_time == (idle_animation_check * 2):
		idle_time = 0


func _on_PlayerSprite_animation_finished():
	$PlayerSprite.play("Idle")
