extends ActionLeaf
class_name MoveRandomly

var movement_duration: float = 2.0
var current_duration: float = 0.0
var current_direction: Vector2 = Vector2.ZERO

func tick(actor: Node, _blackboard: Node) -> int:
	if current_duration <= 0:
		current_direction = Vector2(randi_range(-1, 1), randi_range(-1, 1)).normalized()
		current_duration = movement_duration
	
	current_duration -= get_physics_process_delta_time()
	
	actor.velocity = current_direction * actor.speed
	actor.move_and_slide()
	
	if actor.sprite:
		actor.sprite.play("walk")
		actor.sprite.flip_h = current_direction.x < 0
	
	if current_duration <= 0:
		return SUCCESS
	
	return RUNNING
