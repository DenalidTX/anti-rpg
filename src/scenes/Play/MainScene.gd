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
var game_mode = GameMode.Cutscene

var panel_move_speed = 50

var control_panel_up_position = 512
var control_panel_down_position = 608

var active_enemies = []

# Called when the node enters the scene tree for the first time.
func _ready():
    # TODO: Use this.
    var path_graph = $PathTree.create_default_graph()
    game_mode = GameMode.Cutscene
    $NarrativeBaseNode.show_narrative(0)

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
        if $Control.rect_position.y < control_panel_down_position:
            $Control.rect_position.y += (delta * panel_move_speed)
        # Update paths as needed.
        $EnemyManager.update_paths()
            
func on_start_round():
    print("Start!")
    game_mode = GameMode.Playing
    
    # Add an enemy.
    active_enemies.append($Enemies/Enemy1)
    
    # Get the navigation overlay for enemy pathfinding.
    var enemy_nav : Navigation2D = $LevelMap.get_full_nav()
    var path_graph = $PathTree.create_default_graph()
    $EnemyManager.initialize(active_enemies, enemy_nav, path_graph)

func _on_PlacementArea_gui_input(event):
    if event is InputEventMouseButton && event.pressed:
        if placeable_image != null:
            print("Received placement event.")
            
            if place_mode == PlaceModes.PitTrap:
                place_mode = PlaceModes.None
                $PitNode.add_child_below_node($PitNode/PitCollisionBody, placeable_image)
                placeable_image.rect_position.x = -24
                placeable_image.rect_position.y = -24
                $PitNode.position = get_viewport().get_mouse_position()
                
                # Add collision box.
                $PitNode/PitCollisionBody/PitCollisionShape.disabled = false
                
                # Reset the cursor.
                Input.set_custom_mouse_cursor(null)
                
                # Show the "cover" that hides the pit.
                $PitNode/PitCoverNode.visible = true
                
            elif place_mode == PlaceModes.LargeAntlers:
                place_mode = PlaceModes.None
                $AntlerPile1Node.position = get_viewport().get_mouse_position()
                $AntlerPile1Node.visible = true
                
                # Add collision box.
                $AntlerPile1Node/Antler1CollisionBody/AntlerCollisionShape.disabled = false
                
                # Reset the cursor.
                Input.set_custom_mouse_cursor(null)
                
            elif place_mode == PlaceModes.SmallAntlers:
                place_mode = PlaceModes.None
                $AntlerPile2Node.position = get_viewport().get_mouse_position()
                $AntlerPile2Node.visible = true
                
                # Add collision box.
                $AntlerPile2Node/Antler2CollisionBody/AntlerCollisionShape.disabled = false
                
                # Reset the cursor.
                Input.set_custom_mouse_cursor(null)
