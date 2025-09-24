extends Area2D
class_name HitBox
@export var damage: int = 5  # Synced with enemy’s damage

func _ready() -> void:
	monitoring = false
	monitorable = false
	area_entered.connect(_on_area_entered)
	add_to_group("hitbox")  # For HurtBox detection
	print("HitBox ready: monitoring=", monitoring, " monitorable=", monitorable)
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox") and area.owner != get_parent():
		if area.owner.has_method("take_damage"):
			area.owner.take_damage(damage)
			print("HitBox hit: ", area.owner, " Damage: ", damage)  # Debug
