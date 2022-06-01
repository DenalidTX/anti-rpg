extends Node

# These are used for drawing "ghost" images when placing things.
enum PlaceModes {
    None = 0,
    PitTrap = 1,
    SmallAntlers=2,
    LargeAntlers=3
}
var place_mode = PlaceModes.None
var placeable_image = null

# These are used to track what the player should be able to do.
# Cutscene mode means no controls other than skipping.
# Editor mode lets the player buy and place things.
# Playing mode means that we are working through a level.
enum GameMode {
    Cutscene = 0,
    Editor = 1,
    Playing = 2
}
var game_mode = GameMode.Cutscene

var panel_move_speed = 50

var control_panel_up_position = 512
var control_panel_down_position = 608

# List of lists, where each list is a level.
var active_enemies = []

var current_level = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    
    # Set up the enemy lists for each level.
    active_enemies.append([$Enemies/Enemy1])
    active_enemies.append([$Enemies/Enemy2, $Enemies/Enemy3])
    active_enemies.append([$Enemies/Enemy1, $Enemies/Enemy3, $Enemies/Enemy6])

    game_mode = GameMode.Cutscene
    $NarrativeBaseNode.show_narrative(current_level)

# Called by controls to set the current ghost image and placeable object.
func on_pit_selected(event, image):
    select_placeable(PlaceModes.PitTrap, 'sprites/environment/pit.png')
    
func on_antlers_1_selected(event, image):
    select_placeable(PlaceModes.LargeAntlers, 'sprites/allies/antlerpile_1.png')
                
func on_antlers_2_selected(event, image):
    select_placeable(PlaceModes.SmallAntlers, 'sprites/allies/antlerpile_2.png')

func select_placeable(mode, image_path):
    if place_mode == mode:
        Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
        place_mode = null
    else:
        place_mode = mode
        placeable_image = TextureRect.new()
        placeable_image.texture = load(image_path)
        
        Input.set_custom_mouse_cursor(placeable_image.texture,
                Input.CURSOR_ARROW,
                Vector2(24, 24))
        
func _process(delta):
    if game_mode == GameMode.Cutscene:
        if !$NarrativeBaseNode.showing_narrative():
            game_mode = GameMode.Editor
    elif game_mode == GameMode.Editor:
        if $Control.rect_position.y > control_panel_up_position:
            $Control.rect_position.y -= (delta * panel_move_speed)
    elif game_mode == GameMode.Playing:
        
        if $EnemyManager.level_over():
            reset_placeables()
            current_level += 1
            game_mode = GameMode.Cutscene
            $NarrativeBaseNode.show_narrative(current_level)
        else:
            if $Control.rect_position.y < control_panel_down_position:
                $Control.rect_position.y += (delta * panel_move_speed)
            # Update paths as needed.
            $EnemyManager.update_paths()

func on_start_round():
    print("Start!")
    game_mode = GameMode.Playing
    
    # Get the navigation overlay for enemy pathfinding.
    var enemy_nav : Navigation2D = $LevelMap.get_full_nav()
    var path_graph = $PathTree.create_default_graph()
    $EnemyManager.initialize(active_enemies[current_level], enemy_nav, path_graph)

func reset_placeables():
    $PitNode/PitCollisionBody/PitCollisionShape.disabled = false
    $PitNode/PitCollisionBody/PitAvoidanceShape.disabled = true
    $PitNode/PitCoverNode.visible = true
    $PitNode.position = Vector2(-100, -100)
    
    $AntlerPile1Node.position = Vector2(-100, -100)
    $AntlerPile2Node.position = Vector2(-100, -100)

func _on_PlacementArea_gui_input(event):
    if event is InputEventMouseButton && event.pressed:
        if placeable_image != null:
            print("Received placement event.")
            
            if place_mode == PlaceModes.PitTrap:
                place_mode = PlaceModes.None
                $PitNode.position = get_viewport().get_mouse_position()
                
                # Reset the cursor.
                Input.set_custom_mouse_cursor(null)
                
                # Show the "cover" that hides the pit.
                $PitNode/PitCoverNode.visible = true
                
            elif place_mode == PlaceModes.LargeAntlers:
                place_mode = PlaceModes.None
                $AntlerPile1Node.position = get_viewport().get_mouse_position()
                
                # Reset the cursor.
                Input.set_custom_mouse_cursor(null)
                
            elif place_mode == PlaceModes.SmallAntlers:
                place_mode = PlaceModes.None
                $AntlerPile2Node.position = get_viewport().get_mouse_position()
                
                # Reset the cursor.
                Input.set_custom_mouse_cursor(null)

