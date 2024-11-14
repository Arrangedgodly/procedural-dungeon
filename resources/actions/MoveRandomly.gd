extends ActionLeaf
class_name MoveRandomly

func tick(actor: Node, _blackboard: Node) -> int:
	var direction = Vector2(randf(), randf()).normalized()
	actor.velocity = direction * actor.speed
	actor.move_and_slide()
	
	if actor.sprite:
		actor.sprite.play("walk")
		actor.sprite.flip_h = direction.x < 0
	
	return SUCCESS
