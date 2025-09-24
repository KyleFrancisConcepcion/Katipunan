extends Area2D

signal selection_toggled(selection)

@export var exclusive = true
@export var selection_action = "select"
@onready var Ui := get_parent().get_node('UI/PlayerUi')

var selected: bool = false: set = set_selected

func _My_Ui(showme) -> void:
	Ui.visible = showme


func set_selected(selection: bool):
	if selection:
		_My_Ui(true)
		_make_exclusive()
		add_to_group("selected")
	else:
		_My_Ui(false)
		remove_from_group("selected")
	selected = selection
	emit_signal('selection_toggled', selected)
		 
func _make_exclusive():
	if not exclusive:
		return
	get_tree().call_group("selected","set_selected", false)
	
func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed(selection_action):
		set_selected(not selected)
	
