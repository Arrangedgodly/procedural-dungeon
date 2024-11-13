extends ActionLeaf
class_name MoveTowardsPlayer

func tick(actor: Node, blackboard: Node) -> int:
	if !actor.target:
		return FAILURE
	
	var direction = (actor.target.global_position - actor.global_position).normalized()
	actor.velocity = direction * actor.speed
	actor.move_and_slide()
	
	if actor.sprite:
		actor.sprite.play("walk")
		actor.sprite.flip_h = direction.x < 0
	
	return SUCCESS
