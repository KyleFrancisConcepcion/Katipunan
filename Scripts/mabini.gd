extends CharacterBody2D

@export var Player_name :String = " "
@export var health = 100
@export var health_max = 100
@export var health_min = 0
@export var heal_amount = 10
@export var speed = 175.0
@export var attack_range: float = 100
@export var heal_range: float = 150

var click_position = Vector2()
var target_position = Vector2()
var just_selected = false
var is_auto_attacking: bool = false
var target_enemy: Node = null
var dead:bool= false
var is_hurting: bool = false
@export var heal_cooldown: float = 2.0

signal healthChanged
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var area := get_node('SelectionArea2D')
@onready var hurtbox: Area2D = $AnimatedSprite/HurtBox
@onready var heal_timer: Timer = $HealTimer
@onready var path: NavigationAgent2D = $Path
@onready var pathtimer: Timer = $Pathtimer


func _ready() -> void:
	animated_sprite.play("Idle")
	pathtimer.timeout.connect(_new_path)
	
	click_position = position
	heal_timer.one_shot = true
	heal_timer.wait_time = heal_cooldown
	
	
func _physics_process(delta):
	if dead or is_hurting:
		return
	var current_pos = global_position
	var next_pos = path.get_next_path_position()
	if !is_hurting:
		heal_nearby_allies()
	if area.selected and not just_selected:
		if Input.is_action_just_pressed("select"):
			click_position = get_global_mouse_position()
			_target_position(click_position)
		if position.distance_to(click_position) > 3:
			target_position = (click_position - position).normalized()
			velocity = current_pos.direction_to(next_pos) * (speed + delta) 
			animated_sprite.play("Walk")
			animated_sprite.flip_h = target_position.x < 0
			move_and_slide()
		
	just_selected = false
	
	velocity = Vector2.ZERO
	if path.is_navigation_finished() and heal_timer.time_left==0 and !is_hurting:
		if velocity.is_zero_approx():
			animated_sprite.play("Idle")
		animated_sprite.play("Idle")
		position = click_position
		
	
func _on_selection_area_2d_selection_toggled(selection: Variant) -> void:
	set_process_unhandled_input(selection)
	just_selected = selection
	if not selection:
		click_position = position
		velocity = Vector2.ZERO
	
func take_damage(amount: int):
	if dead or is_hurting:
		return
	animated_sprite.play("Hurt")
	is_hurting = true
	health = max(health - amount, 0)
	await get_tree().create_timer(1.5).timeout
	is_hurting = false
	if health <= 0:
		die()
			
func die()-> void:
	dead = true
	animated_sprite.play("Death")
	$sfx_death.play()
	await animated_sprite.animation_finished
	queue_free()
	
func heal_nearby_allies() -> void:
	var allies = get_tree().get_nodes_in_group("allies")
	var closest_ally = null
	var closest_distance = heal_range + 1
	
	for ally in allies:
		if ally == self or not ally.has_method("heal") or dead:
			continue
		var distance = global_position.distance_to(ally.global_position)
		if distance <= heal_range and distance < closest_distance:
			if ally.health < ally.health_max:
				if heal_timer.time_left > 0:
					return
				animated_sprite.play("Heal")
				closest_distance = distance
				closest_ally = ally
				heal_timer.start()
				closest_ally.heal(heal_amount)
				$sfx_heal.play()
				await animated_sprite.animation_finished
				#For debugging
				#print("healed", closest_ally.name, ". cooldown started.")
func heal(amount: int) -> void:
	if dead:
		return
	health = min(health + amount, health_max)
	emit_signal("healthChanged")
	#For debugging
	#print("Healed for ", amount, ". Current health: ", health)
	

func _target_position(target: Vector2) -> void:
	path.target_position = target
	
func _new_path() -> void:
	_target_position(path.target_position)
	if path.is_target_reached():
		position = global_position
