extends MeleeEnemy
class_name Eyeslime

func _ready() -> void:
	health = 15
	speed = 75
	damage = 15
	attack_range = 25
	approach_range = 300
	super._ready()

func attack_player() -> void:
	# Basic melee attacker that jumps at the player
	sprite.play("attack")
	if target and get_distance_to_player() <= attack_range:
		# Jump towards player
		var jump_direction = (target.global_position - global_position).normalized()
		velocity = jump_direction * speed * 1.5
		await sprite.animation_finished
		if target and get_distance_to_player() <= attack_range:
			target.take_damage(damage)
	attack_timer.start()
