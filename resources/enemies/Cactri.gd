extends MeleeEnemy
class_name Cactri

var can_damage: bool = true

func _ready() -> void:
	health = 30
	speed = 30
	damage = 50
	approach_range = 250
	attack_range = 15
	super._ready()

func attack_player() -> void:
	if !can_damage or !target:
		return
		
	sprite.play("attack")
	can_damage = false
	
	if get_distance_to_player() <= attack_range:
		target.take_damage(damage)
	
	# Add attack cooldown
	await get_tree().create_timer(1.0).timeout
	can_damage = true
	attack_timer.start()
