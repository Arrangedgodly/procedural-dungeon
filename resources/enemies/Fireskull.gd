extends Enemy
class_name Fireskull

const FIREBALL = preload("res://scenes/projectiles/fireball.tscn")

func _ready() -> void:
	health = 75
	speed = 50
	damage = 30
	approach_range = 500
	attack_range = 100
	attack_cooldown = 2.5

func attack_player() -> void:
	if is_dead:
		return
	
	var fireball = FIREBALL.instantiate()
	fireball.set_damage(damage)
	get_tree().get_first_node_in_group("projectiles").add_child(fireball)
	fireball.global_position = global_position
	fireball.set_target(target)
	fireball.launch(target.global_position)
