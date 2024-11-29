extends Pickup
class_name HealthPack

@export var heal_amount: int = 25

func collect() -> void:
	if target and target.has_method("heal_damage"):
		target.heal_damage(heal_amount)
	super.collect()
