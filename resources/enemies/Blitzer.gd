extends Enemy
class_name Blitzer

var direction: Vector2

func _ready() -> void:
	health = 30
	speed = 200
	damage = 75
	sprite.sprite_frames.set_animation_loop("attack", true)
	approach_range = 1000
	attack_range = 500
	super._ready()

func _process(delta: float) -> void:
	position += direction * speed * delta
	sprite.flip_h = direction.x < 0
	move_and_slide()
	
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
