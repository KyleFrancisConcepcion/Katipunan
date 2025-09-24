extends Control

func _ready() -> void:
	hide()
	$AnimationPlayer.play("RESET")
# Called when the node enters the scene tree for the first time.
func resume():
	$AnimationPlayer.play_backwards("Blur")
	hide()
	get_tree().paused = false
	
func pause():
	$AnimationPlayer.play("Blur")
	show()
	get_tree().paused = true
func testEsc():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused == true:
		resume() 

func _process(delta: float) -> void:
	testEsc()
	
func _on_resume_pressed() -> void:
	resume()
 
func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()
