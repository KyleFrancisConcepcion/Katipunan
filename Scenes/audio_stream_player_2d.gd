extends AudioStreamPlayer2D

@export var loop_sound: bool = true

func _ready():
	_on_finished()

func _on_finished():
	if loop_sound:
		play()   
