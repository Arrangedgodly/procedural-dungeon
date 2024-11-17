extends Enemy
class_name Blitzer

var is_attacking: bool = false
var direction: Vector2

func _ready() -> void:
	health = 30
	speed = 300
	damage = 20
	sprite.sprite_frames.set_animation_loop("attack", true)
	approach_range = 1000
	attack_range = 500

func attack_player() -> void:
	if is_attacking:
		return
	
	if sprite:
		sprite.play("attack")
	
	is_attacking = true
	
func _process(delta: float) -> void:
	if is_attacking and target != null:
		direction = (target.global_position - global_position).normalized()
		position += direction * speed * delta
		move_and_slide()
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider() == target:
				target.take_damage(damage)
				sprite.play("idle")
				await sprite.animation_looped
				is_attacking = false
