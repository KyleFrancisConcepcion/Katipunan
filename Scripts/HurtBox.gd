extends Area2D
class_name HurtBox


func _ready() -> void:
	monitoring = true
	monitorable = true
	area_entered.connect(_on_area_entered)
	add_to_group("hurtbox")  # For HitBox detection
	print("HurtBox ready: monitoring=", monitoring, " monitorable=", monitorable)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("hitbox") and area.owner != get_parent():
		var damage_amount = area.damage if "damage" in area else 5
		get_parent().take_damage(damage_amount)
		print("HurtBox hit: ", get_parent(), " Damage: ", damage_amount)  # Debug
