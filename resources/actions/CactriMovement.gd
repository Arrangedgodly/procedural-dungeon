extends ActionLeaf
class_name CactriMovement

func tick(actor: Node, _blackboard: Node) -> int:
	if !actor.target or actor.is_attacking:
		return FAILURE
	
	var to_player = actor.target.global_position - actor.global_position
	var distance = to_player.length()
	var is_above = actor.global_position.y >= actor.target.global_position.y
	
	actor.velocity = Vector2.ZERO
	
	if is_above:
		var circle_direction = Vector2(-to_player.y, to_player.x).normalized()
		if actor.global_position.x < actor.target.global_position.x:
			circle_direction = -circle_direction
		actor.velocity = circle_direction * actor.speed
	else:
		var direction = Vector2(to_player.x, to_player.y).normalized()
		actor.velocity = direction * actor.speed
	
	if actor.velocity != Vector2.ZERO:
		actor.move_and_slide()
		actor.sprite.play("walk")
		actor.sprite.flip_h = actor.velocity.x < 0
	else:
		actor.sprite.play("idle")
	
	return SUCCESS