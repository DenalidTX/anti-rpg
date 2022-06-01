extends Button

signal start_round()

# Called when the node enters the scene tree for the first time.
func _ready():
    connect("start_round", 
            owner, 
            "on_start_round")

func _on_StartRoundButton_pressed():
    emit_signal("start_round")
