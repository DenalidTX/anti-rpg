extends Control

signal pit_selected(event, image)
signal antlers_1_selected(event, image)
signal antlers_2_selected(event, image)
signal start_round()

# Called when the node enters the scene tree for the first time.
func _ready():
    connect("pit_selected", 
            owner, 
            "on_pit_selected")
            
    connect("start_round", 
            owner, 
            "on_start_round")
            
    connect("antlers_1_selected", 
            owner, 
            "on_antlers_1_selected")
            
    connect("antlers_2_selected", 
            owner, 
            "on_antlers_2_selected")

# Called by controls to set the current ghost image and placeable object.
func on_pit_selected(event, image):
    emit_signal("pit_selected", event, image)

func on_antlers_1_selected(event, image):
    emit_signal("antlers_1_selected", event, image)

func on_antlers_2_selected(event, image):
    emit_signal("antlers_2_selected", event, image)

# Called by controls to set the current ghost image and placeable object.
func on_start_round():
    emit_signal("start_round")
