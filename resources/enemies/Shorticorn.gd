extends MeleeEnemy
class_name Shorticorn

func _ready() -> void:
	health = 50
	speed = 100
	damage = 20
	attack_range = 35
	approach_range = 200
	super._ready()

func attack_player() -> void:
	var charge_count = 0
	var max_charges = 3
	
	while charge_count < max_charges:
		sprite.play("attack")
		if target and get_distance_to_player() <= attack_range * 2:
			var charge_dir = (target.global_position - global_position).normalized()
			velocity = charge_dir * speed * 2
			move_and_slide()
			
			if get_distance_to_player() <= attack_range:
				target.take_damage(damage)
				charge_count += 1
				await get_tree().create_timer(0.3).timeout
		else:
			break
			
	velocity = Vector2.ZERO
	attack_timer.start()
