extends CanvasLayer

@onready var to_kill: Label = $Panel/HBoxContainer/To_kill


func _process(_delta: float) -> void:
	to_kill.text = str(get_parent().Max_Enimies - get_parent().enemy_killed)
