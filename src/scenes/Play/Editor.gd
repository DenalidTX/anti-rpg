extends Node

# TODO: Is this needed?
enum PlaceModes {
	None = 0,
	PitTrap = 1
}

# This is used for drawing "ghost" images when placing things.
var pit_image = null
var place_mode = PlaceModes.None

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called by controls to set the current ghost image and placeable object.
func on_pit_selected(event, image):
	print("Caught event! (Editor)")
	if pit_image == null:
		place_mode = PlaceModes.PitTrap
		pit_image = TextureRect.new()
		pit_image.texture = load('sprites/environment/pit.png')
		
		Input.set_custom_mouse_cursor(pit_image.texture,
				Input.CURSOR_ARROW,
				Vector2(24, 24))

func _on_PlacementArea_gui_input(event):
	if event is InputEventMouseButton && event.pressed:
		if pit_image != null and place_mode == PlaceModes.PitTrap:
			print("Received placement event.")
			place_mode = PlaceModes.None
			$PitNode.add_child(pit_image)
			pit_image.rect_position = get_viewport().get_mouse_position()
			pit_image.rect_position.x -= 24 # Adjust for mouse being centered.
			pit_image.rect_position.y -= 24 # Adjust for mouse being centered.
			Input.set_custom_mouse_cursor(null)
