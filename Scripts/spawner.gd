extends Node2D

# Export variables for Inspector configuration
@export var spawn_scene: PackedScene # Scene to spawn (e.g., Enemy.tscn)
@export var min_spawn_time: float = 1.0
@export var max_spawn_time: float = 3.0
@export var max_enemies: int = 5
@export var spawn_margin: float = 50.0
@export var total_enemies_to_spawn: int = 10 # Total enemies to spawn before win
var rng = RandomNumberGenerator.new()
var active_enemies: int = 0
var total_spawned: int = 0 # Tracks total enemies spawned
var viewport_rect: Rect2

func _ready():
	rng.randomize()
	viewport_rect = get_viewport_rect()
	$Timer.wait_time = rng.randf_range(min_spawn_time, max_spawn_time)
	$Timer.start()

func _on_timer_timeout():
	# Spawn only if under max_enemies, scene is assigned, and total limit not reached
	if active_enemies < max_enemies and spawn_scene != null and total_spawned < total_enemies_to_spawn:
		var instance = spawn_scene.instantiate()
		instance.global_position = get_random_spawn_position()
		if instance.has_signal("tree_exited"):
			instance.connect("tree_exited", _on_enemy_exited)
		get_tree().root.add_child(instance)
		active_enemies += 1
		total_spawned += 1
		print("Spawned enemy at: ", instance.global_position, " (Side: ", get_side_name(instance.global_position), ")")
		$Timer.wait_time = rng.randf_range(min_spawn_time, max_spawn_time)
		$Timer.start()
	else:
		# Stop timer if total enemies reached
		if total_spawned >= total_enemies_to_spawn:
			$Timer.stop()
			# Check win condition in _process
			set_process(true)

#func _process(delta):
	## Check win condition: all enemies spawned and none active
	#if total_spawned >= total_enemies_to_spawn and active_enemies == 0 and victory_screen_scene != null:
		#var victory_screen = victory_screen_scene.instantiate()
		#get_tree().root.add_child(victory_screen)
		#set_process(false) # Stop checking
		#print("Victory screen shown!")

func get_random_spawn_position() -> Vector2:
	var camera = get_viewport().get_camera_2d()
	var camera_offset = camera.global_position if camera else Vector2.ZERO
	var min_x = viewport_rect.position.x + camera_offset.x - spawn_margin
	var max_x = viewport_rect.position.x + viewport_rect.size.x + camera_offset.x + spawn_margin
	var min_y = viewport_rect.position.y + camera_offset.y - spawn_margin
	var max_y = viewport_rect.position.y + viewport_rect.size.y + camera_offset.y + spawn_margin
	var side = rng.randi_range(0, 3)
	var x: float
	var y: float
	match side:
		0: x = rng.randf_range(min_x, max_x); y = min_y
		1: x = max_x; y = rng.randf_range(min_y, max_y)
		2: x = rng.randf_range(min_x, max_x); y = max_y
		3: x = min_x; y = rng.randf_range(min_y, max_y)
	return Vector2(x, y)

func get_side_name(pos: Vector2) -> String:
	var camera = get_viewport().get_camera_2d()
	var camera_offset = camera.global_position if camera else Vector2.ZERO
	var min_x = viewport_rect.position.x + camera_offset.x - spawn_margin
	var max_x = viewport_rect.position.x + viewport_rect.size.x + camera_offset.x + spawn_margin
	var min_y = viewport_rect.position.y + camera_offset.y - spawn_margin
	var max_y = viewport_rect.position.y + viewport_rect.size.y + camera_offset.y + spawn_margin
	if abs(pos.y - min_y) < 1.0:
		return "Top"
	elif abs(pos.x - max_x) < 1.0:
		return "Right"
	elif abs(pos.y - max_y) < 1.0:
		return "Bottom"
	elif abs(pos.x - min_x) < 1.0:
		return "Left"
	return "Unknown"

func _on_enemy_exited():
	active_enemies -= 1
	print("Enemy exited, active_enemies: ", active_enemies)
