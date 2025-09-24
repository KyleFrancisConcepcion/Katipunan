extends CharacterBody2D


@export var health = 150
@export var health_max = 150
@export var health_min = 0
@export var damage = 50
@export var speed: float = 200
@export var detection_range: float = 500.0
@export var stop_distance: float = 100.0
@export var attack_cooldown:float = 1.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $AnimatedSprite2D/HitBox
@onready var hurtbox: Area2D = $AnimatedSprite2D/HurtBox
@onready var attack_timer: Timer = $AttackTimer

var target:Node = null
var can_attack: bool = true
var dead: bool = false
var is_hurting = false
signal healthChanged

func _ready() -> void:
	health = clamp(health,health_min,health_max)
	if not attack_timer:
		attack_timer = Timer.new()
		attack_timer.name = "AttackTimer"
		attack_timer.wait_time = attack_cooldown
		attack_timer.one_shot = true
		attack_timer.timeout.connect(_on_attack_timer_timeout)
		add_child(attack_timer)
	
func _physics_process(_delta: float) -> void:
	if dead or is_hurting:
		return
	update_target()
	velocity = Vector2.ZERO
	if target:
		var distance_to_target: float = global_position.distance_to(target.global_position)
		update_sprite_facing()
		if distance_to_target > stop_distance:
			velocity = (target.position - position).normalized() * speed
			animated_sprite_2d.play("Walk")
		else:
			animated_sprite_2d.play("Attack")
			$sfx_hit.play()
			if can_attack:
				attack()
	move_and_slide()

func update_sprite_facing() -> void:
	# Option 1: Flip sprite (for side-scrolling games)
	var direction: Vector2 = (target.global_position - global_position).normalized()
	if direction.x > 0:
		animated_sprite_2d.scale.x = 1
	elif direction.x < 0:
		animated_sprite_2d.scale.x = -1


func update_target():
	var players = get_tree().get_nodes_in_group("player")
	var dmg_player = get_tree().get_nodes_in_group("dmg_player")
	var closest_player: Node = null
	var closest_distance: float = detection_range
	
	if not target:
		for character in dmg_player:
			var distance = global_position.distance_to(character.global_position)
			closest_distance = distance
			closest_player = character
				
	for player in players:
		var distance = global_position.distance_to(player.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_player = player
	target = closest_player
	
func attack() -> void:
	can_attack = false
	attack_timer.start()
	hitbox.monitoring=true
	#print("attack")
	await animated_sprite_2d.animation_finished
	hitbox.monitoring = false
	
func take_damage(amount: int) -> void:
	if dead or is_hurting:
		return
	health = max(health - amount, 0)
	is_hurting = true
	animated_sprite_2d.play("Hurt")
	await animated_sprite_2d.animation_finished
	is_hurting = false
	if health <= 0 and not dead:
		dead = true	
		health = 0
		animated_sprite_2d.play("Death")
		$sfx_death.play()
		await animated_sprite_2d.animation_finished
		get_parent().spawn_another(1)
		get_parent().enemy_killed += 1
		queue_free()
		
func _on_attack_timer_timeout() -> void:
	can_attack = true

func _on_hurt_box_area_entered(hitbox) -> void:
	var base_damage = hitbox.damage
	self.health -= base_damage
	#print(hitbox.get_parent().get_parent().name + "'s")
	
	
