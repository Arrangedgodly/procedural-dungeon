extends MeleeEnemy
class_name Clawtzer

func _ready() -> void:
	health = 35
	speed = 125
	damage = 20
	attack_range = 35
	approach_range = 500
	super._ready()

func attack_player() -> void:
	if !attack_timer.is_stopped():
		return
		
	sprite.play("attack")
	# First hit
	if target and get_distance_to_player() <= attack_range:
		target.take_damage(damage)
	await sprite.animation_finished
	
	# Second hit
	if target and get_distance_to_player() <= attack_range:
		sprite.play("attack")
		target.take_damage(damage)
	await sprite.animation_finished
	
	# Final hit
	if target and get_distance_to_player() <= attack_range:
		sprite.play("attack") 
		target.take_damage(damage * 1.5) # Bonus damage on final hit
	
	attack_timer.start()
