extends MeleeEnemy
class_name Blitzer

var direction: Vector2

func _ready() -> void:
	health = 30
	speed = 120
	damage = 75
	sprite.sprite_frames.set_animation_loop("attack", true)
	approach_range = 750
	attack_range = 300
	super._ready()
	
func attack_player() -> void:
	if is_dead:
		return
		
	if target != null:
		direction = (target.global_position - global_position).normalized()
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider() == target:
				target.take_damage(damage)
				sprite.play("idle")
