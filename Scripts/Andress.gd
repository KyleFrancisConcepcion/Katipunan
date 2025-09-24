extends CharacterBody2D

@export var Player_name :String = " "
@export var health = 100
@export var health_max = 100
@export var health_min = 0
@export var damage = 10
@export var speed = 300

var click_position = Vector2()
var target_position = Vector2()
var just_selected = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite
@onready var area = $SelectionArea2D
@onready var hitbox: Area2D = $AnimatedSprite/HitBox
@onready var player_ui: PanelContainer = $UI/PlayerUi
@onready var attack_timer: Timer = $AttackTimer
@onready var hurtbox: Area2D = $AnimatedSprite/HurtBox
@export var detection_range: float = 500.0
@export var stop_distance: float = 100.0
@export var attack_cooldown:float = 1.0
@onready var path: NavigationAgent2D = $Path
@onready var pathtimer: Timer = $Pathtimer

var target:Node = null
var can_attack: bool = true
var dead = false
var is_hurting = false

func _ready() -> void:
	pathtimer.timeout.connect(_new_path)
	player_ui.hide()
	click_position = position
	
	
func _physics_process(delta):
	if dead or is_hurting:
		return
	var current_pos = global_position
	var next_pos = path.get_next_path_position()
	if area.selected and not just_selected:
		if Input.is_action_just_pressed("select"):
			click_position = get_global_mouse_position()
			_target_position(click_position)
		if position.distance_to(click_position) > 3:
			target_position = (click_position - position).normalized()
			#velocity = target_position * speed	
			#animated_sprite.flip_h = target_position.x < 0
			velocity = current_pos.direction_to(next_pos) * (speed + delta) 
			animated_sprite.play("Walk")
			animated_sprite.flip_h = target_position.x < 0
			move_and_slide()
			
	just_selected = false
	update_target()
	velocity = Vector2.ZERO
	if path.is_navigation_finished() and !is_hurting:
		if velocity.is_zero_approx():
			animated_sprite.play("Idle")
		animated_sprite.play("Idle")
		position = click_position
		
	if target:
		var distance_to_target: float = global_position.distance_to(target.global_position)
		if distance_to_target > stop_distance:
			animated_sprite.play("Walk")
			velocity = (target.position - position).normalized() * speed
		else:
			animated_sprite.play("Attack")
			$sfx_hit.play()
			await animated_sprite.animation_finished
			if can_attack:
				attack()
	
func update_target():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var closest_enemies: Node = null
	var closest_distance: float = detection_range
	
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemies = enemy
	target = closest_enemies
	
func attack() -> void:
	can_attack = false
	attack_timer.start()
	hitbox.monitoring=true
	#print("attack")
	await animated_sprite.animation_finished
	hitbox.monitoring = false
	
func take_damage(amount: int) -> void:
	if dead or is_hurting:
		return
	health = max(health - amount, 0)
	is_hurting = true
	animated_sprite.play("Hurt")
	#print("Player hit, health: ", health)
	await animated_sprite.animation_finished
	is_hurting = false
	if health <= 0 and not dead:
		dead = true	
		health = 0
		animated_sprite.play("Death")
		$sfx_death.play()
		await animated_sprite.animation_finished
		queue_free()
		
		
func _on_selection_area_2d_selection_toggled(selection: Variant) -> void:
	set_process_unhandled_input(selection)
	just_selected = selection
	if not selection:
		click_position = position
		velocity = Vector2.ZERO
		
func _on_hurt_box_area_entered(hitbox) -> void:
	var base_damage = damage.damage
	self.health -= base_damage
	#print(hitbox.get_parent().name + "'s")

func heal(amount: int) -> void:
	if dead:
		return
	health = min(health + amount, health_max)
	
	
func _on_attack_timer_timeout() -> void:
	can_attack = true

func _target_position(target: Vector2) -> void:
	path.target_position = target
	
func _new_path() -> void:
	_target_position(click_position)
	if path.is_target_reached():
		position = click_position
