extends Pickup
class_name HealthPack

@export var heal_amount: int = 25

func _on_body_entered(body: Node2D) -> void:
	if !is_being_collected and body.is_in_group("player"):
		if body.has_method("heal_damage"):
			body.heal_damage(heal_amount)
		collect()

func collect() -> void:
	if collect_sound:
		SoundManager.play_sfx(collect_sound, "Pickups", global_position)
	collected.emit(target)
	queue_free()

func should_auto_collect(player: Node2D) -> bool:
	if !player.has_method("get_missing_health"):
		return false
	
	var missing_health = player.get_missing_health()
	return missing_health >= heal_amount
