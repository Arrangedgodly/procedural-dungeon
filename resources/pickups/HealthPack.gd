extends Pickup
class_name HealthPack

@export var heal_amount: int = 25

func collect() -> void:
	if target and target.has_method("heal_damage"):
		target.heal_damage(heal_amount)
	super.collect()

func should_auto_collect(player: Node2D) -> bool:
	if !player.has_method("get_missing_health"):
		return false
	
	var missing_health = player.get_missing_health()
	return missing_health >= heal_amount
