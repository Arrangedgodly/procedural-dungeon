extends ActionLeaf
class_name StrategicMovement

@export var optimal_distance: float = 150.0
@export var distance_tolerance: float = 20.0
@export var strafe_time: float = 1.0
var strafe_timer: float = 0.0
var strafe_direction: float = 1.0

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if !actor.target:
		return FAILURE
	
	var distance = actor.get_distance_to_player()
	var to_target = actor.target.global_position - actor.global_position
	var direction = to_target.normalized()
	
	if strafe_timer <= 0:
		strafe_timer = strafe_time
		strafe_direction = 1.0 if randf() > 0.5 else -1.0
	
	strafe_timer -= get_physics_process_delta_time()
	
	if abs(distance - optimal_distance) <= distance_tolerance:
		# Strafe perpendicular to the target
		direction = direction.rotated(PI/2 * strafe_direction)
	elif distance < optimal_distance:
		direction = -direction
	
	actor.velocity = direction * actor.speed
	actor.move_and_slide()
	
	if actor.sprite:
		actor.sprite.play("walk")
		actor.sprite.flip_h = direction.x < 0
	
	return SUCCESS
