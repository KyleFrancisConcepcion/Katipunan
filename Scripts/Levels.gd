extends Node

@export var Current_Level := 1
@export var Max_Enimies := 5
@export var next_scene: PackedScene # Scene to transition to (e.g., Level2.tscn)

@onready var Spawner := get_node('EnemySpawner')
@onready var victoryload := preload('res://Scenes/victory_screen.tscn')


var current_enemy_count := 0
var enemy_killed := 0

func _ready() -> void:
	Spawner.spawn_enemy(1)

func _process(delta: float) -> void:
	if enemy_killed == Max_Enimies:
		var victory_inst = victoryload.instantiate()
		add_child(victory_inst)


func spawn_another(value):
	await get_tree().create_timer(3.0).timeout
	if current_enemy_count < Max_Enimies:
		Spawner.spawn_enemy(value)
	
