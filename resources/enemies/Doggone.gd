extends MeleeEnemy
class_name Doggone

func _ready() -> void:
	health = 10
	speed = 150
	damage = 10
	attack_range = 18
	approach_range = 400
	super._ready()

func attack_player() -> void:
	sprite.play("attack")
	
	if target and get_distance_to_player() <= attack_range:
		target.take_damage(damage)
		for i in range(2):
			if target and get_distance_to_player() <= attack_range:
				await get_tree().create_timer(0.2).timeout
				sprite.play("attack")
				target.take_damage(damage)
	
	attack_timer.start()
