extends Enemy
class_name Blitzer

var is_attacking: bool = false
var direction: Vector2

func _ready() -> void:
	health = 30
	speed = 100
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
		var collision = move_and_collide(velocity * delta)
		if collision:
			handle_collision(collision)
			
func handle_collision(collision: KinematicCollision2D) -> void:
	target.take_damage(damage)
	target.knock_back(position.direction_to(target.position))
