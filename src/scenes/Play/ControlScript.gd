extends Control

signal pit_selected(event, image)

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("pit_selected", 
			owner, 
			"on_pit_selected")

# Called by controls to set the current ghost image and placeable object.
func on_pit_selected(event, image):
	print("Caught event! (Control Script)")
	emit_signal("pit_selected", event, image)
