extends MeleeEnemy
class_name Cactri

func _ready() -> void:
	health = 30
	speed = 30
	damage = 50
	approach_range = 250
	attack_range = 15
	super._ready()

func attack_player() -> void:
	sprite.play("attack")
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() == target:
			target.take_damage(damage)
