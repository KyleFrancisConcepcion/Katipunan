extends Node2D

@onready var loadenemy = preload("res://Scenes/enemy.tscn")

@export var Max_Spawn_Time :float = 2.0


func spawn_enemy(amount: int) -> void:
	var level = get_parent()
	for i in amount:
		await get_tree().create_timer(1.0).timeout
		var enemyinst = loadenemy.instantiate()
		enemyinst.position = global_position
		level.add_child(enemyinst)
		level.current_enemy_count += 1
