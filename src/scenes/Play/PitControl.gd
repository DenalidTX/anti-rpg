extends TextureRect

signal pit_selected(event, image)

var mode = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    connect("pit_selected", 
            owner, 
            "on_pit_selected")

func _gui_input(event):
    if event.is_action("select_placeable") \
        and Input.is_mouse_button_pressed(BUTTON_LEFT):
            emit_signal("pit_selected", event, self.get("texture"))
