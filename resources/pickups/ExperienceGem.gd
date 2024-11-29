extends Pickup
class_name ExperienceGem

@export var experience_value: int = 1

func collect() -> void:
	if target and target.has_method("gain_experience"):
		target.gain_experience(experience_value)
	super.collect()
