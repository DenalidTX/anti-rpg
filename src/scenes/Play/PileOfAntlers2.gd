extends TextureRect

signal antlers_2_selected(event, image)

# Called when the node enters the scene tree for the first time.
func _ready():
    connect("antlers_2_selected", 
            owner, 
            "on_antlers_2_selected")

func _gui_input(event):
    if event.is_action("select_placeable") \
        and Input.is_mouse_button_pressed(BUTTON_LEFT):
            emit_signal("antlers_2_selected", event, self.get("texture"))
