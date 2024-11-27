extends Enemy
class_name MeleeEnemy

func _ready() -> void:
	keep_distance = false
	super._ready()

func attack_player() -> void:
	sprite.play("attack")
	if target and get_distance_to_player() <= attack_range:
		target.take_damage(damage)
	attack_timer.start()
