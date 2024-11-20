extends ActionLeaf
class_name PlayDeath

func tick(actor: Node, _blackboard: Node) -> int:
	if actor.sprite:
		actor.is_dead = true
		actor.sprite.play("death")
	
	return SUCCESS
