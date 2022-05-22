extends Node

# These are used for drawing "ghost" images when placing things.
enum PlaceModes {
    None = 0,
    PitTrap = 1
}
var pit_image = null
var place_mode = PlaceModes.None
var pits_remaining = 1

# These are used to track what the player should be able to do.
# Cutscene mode means no controls other than skipping.
# Editor mode lets the player buy and place things.
# Playing mode means that we are working through a level.
enum GameMode {
    Cutscene = 0,
    Editor = 1,
    Playing = 2
}
var game_mode = GameMode.Editor

var panel_move_speed = 50

var control_panel_up_position = 512
var control_panel_down_position = 608

var active_enemies = []

# Called when the node enters the scene tree for the first time.
func _ready():
    pass

# Called by controls to set the current ghost image and placeable object.
func on_pit_selected(event, image):
    #print("Caught event! (Editor)")
    if pit_image == null:
        place_mode = PlaceModes.PitTrap
        pit_image = TextureRect.new()
        pit_image.texture = load('sprites/environment/pit.png')
        
        Input.set_custom_mouse_cursor(pit_image.texture,
                Input.CURSOR_ARROW,
                Vector2(24, 24))

func _process(delta):
    if game_mode == GameMode.Playing:
        if $Control.rect_position.y < control_panel_down_position:
            $Control.rect_position.y += (delta * panel_move_speed)
        # Update paths as needed.
        $EnemyManager.update_paths()
    elif game_mode == GameMode.Editor:
        if $Control.rect_position.y > control_panel_up_position:
            $Control.rect_position.y -= (delta * panel_move_speed)
            
func on_start_round():
    print("Start!")
    game_mode = GameMode.Playing
    
    # Add an enemy.
    active_enemies.append($Enemies/Enemy1)
    
    # Get the navigation overlay for enemy pathfinding.
    var enemy_nav : Navigation2D = $LevelMap.get_enemy_path_nav()
    var pathing_targets = [
            $PathEnd1.position, 
            $PathEnd2.position, 
            $PathFork.position
        ]
    $EnemyManager.initialize(active_enemies, enemy_nav, pathing_targets)

func _on_PlacementArea_gui_input(event):
    if event is InputEventMouseButton && event.pressed:
        if pit_image != null and place_mode == PlaceModes.PitTrap:
            print("Received placement event.")
            place_mode = PlaceModes.None
            $PitNode.add_child(pit_image)
            pit_image.rect_position = get_viewport().get_mouse_position()
            pit_image.rect_position.x -= 24 # Adjust for mouse being centered.
            pit_image.rect_position.y -= 24 # Adjust for mouse being centered.
            
            # Add collision box.
            $PitNode/PitCollisionBody.position = get_viewport().get_mouse_position()
            $PitNode/PitCollisionBody/PitCollisionShape.disabled = false
            Input.set_custom_mouse_cursor(null)
