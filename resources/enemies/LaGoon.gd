extends MeleeEnemy
class_name LaGoon

func _ready() -> void:
	health = 25
	speed = 200
	damage = 15
	attack_range = 30
	approach_range = 300
	super._ready()

func attack_player() -> void:
	# Fast multi-slash attacker
	sprite.play("attack")
	
	for i in range(3):
		if target and get_distance_to_player() <= attack_range:
			target.take_damage(damage)
			# Quick dash between slashes
			var dash_dir = (target.global_position - global_position).normalized()
			velocity = dash_dir * speed * 0.5
			move_and_slide()
		await get_tree().create_timer(0.15).timeout
	
	attack_timer.start()
