extends ActionLeaf
class_name CirclingMovement

@export var circle_radius: float = 150.0
@export var circle_speed: float = 2.0
var angle: float = 0.0

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if !actor.target:
		return FAILURE
		
	angle += circle_speed * get_physics_process_delta_time()
	
	# Calculate ideal position on the circle around the target
	var circle_position = actor.target.global_position + Vector2(
		cos(angle) * circle_radius,
		sin(angle) * circle_radius
	)
	
	# Move towards the calculated position
	var direction = (circle_position - actor.global_position).normalized()
	actor.velocity = direction * actor.speed
	actor.move_and_slide()
	
	if actor.sprite:
		actor.sprite.play("walk")
		actor.sprite.flip_h = direction.x < 0
	
	return SUCCESS
