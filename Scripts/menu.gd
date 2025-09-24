extends Control

@onready var mainbuttons: VBoxContainer = $Mainbuttons
@onready var option_menu: Panel = $OptionMenu

func _process(delta: float) -> void:
	pass

func _ready() -> void:
	mainbuttons.visible = true
	option_menu.visible = false
	

func _on_start_pressed() -> void:
	self.hide()
	var level = preload("res://Scenes/Level 0.tscn")
	var level_inst = level.instantiate()
	var main = get_parent()
	main.add_child(level_inst)
	#get_tree().change_scene_to_file("res://Scenes/node_2d.tscn")
	
func _on_options_pressed() -> void:
	mainbuttons.visible = false
	option_menu.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	_ready()
