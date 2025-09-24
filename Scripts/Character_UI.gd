extends Node


@export var Icon := AnimatedSprite2D
@onready var player := get_parent()
@onready var health_bar: ProgressBar = $PlayerUi/HBoxContainer/VBoxContainer/HealthBar2
@onready var label: Label = $PlayerUi/HBoxContainer/VBoxContainer/Label
@onready var player_ui: PanelContainer = $PlayerUi
@onready var hurt: Panel = $PlayerUi/Hurt



func _ready() -> void:
	player_ui.hide()
	label.text = player.Player_name

func _process(_delta: float) -> void:
	health_bar.value = player.health
	hurt.visible = player.is_hurting
