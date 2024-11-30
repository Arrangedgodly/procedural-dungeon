extends Pickup
class_name ExperienceGem

@export var experience_value: int = randi_range(1, 3)

func _on_body_entered(body: Node2D) -> void:
	if !is_being_collected and body.is_in_group("player"):
		if body.has_method("gain_experience"):
			body.gain_experience(experience_value)
		collect()

func collect() -> void:
	if collect_sound:
		SoundManager.play_sfx(collect_sound, "Pickups", global_position)
	collected.emit(target)
	queue_free()

func should_auto_collect(player: Node2D) -> bool:
	return true
