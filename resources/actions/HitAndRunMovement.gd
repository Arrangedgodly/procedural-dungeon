extends ActionLeaf
class_name HitAndRunMovement

enum State { APPROACH, RETREAT }
@export var retreat_distance: float = 250.0
@export var attack_distance: float = 100.0

var current_state: State = State.APPROACH

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if !actor.target:
		return FAILURE
	
	var distance = actor.get_distance_to_player()
	var direction: Vector2
	
	match current_state:
		State.APPROACH:
			if distance <= attack_distance:
				current_state = State.RETREAT
			direction = (actor.target.global_position - actor.global_position).normalized()
			
		State.RETREAT:
			if distance >= retreat_distance:
				current_state = State.APPROACH
			direction = (actor.global_position - actor.target.global_position).normalized()
	
	actor.velocity = direction * actor.speed
	actor.move_and_slide()
	
	if actor.sprite:
		actor.sprite.play("walk")
		actor.sprite.flip_h = direction.x < 0
	
	return SUCCESS
