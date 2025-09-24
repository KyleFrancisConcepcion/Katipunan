extends CanvasLayer

func _ready():
	get_tree().paused = true
	
func go_to_next_scene():
	if get_parent().next_scene != null:
		get_tree().paused = false
		get_tree().change_scene_to_packed(get_parent().next_scene)
		get_parent().free()
	else:
		print("Error: Next scene not assigned!")

func _on_exit_pressed() -> void:
	get_tree().quit()
	
