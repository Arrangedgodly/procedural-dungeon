extends ActionLeaf
class_name PlayDeath

func tick(actor: Node, _blackboard: Node) -> int:
	if actor.sprite:
		actor.sprite.play("death")
		actor.is_dead = true
	
	return SUCCESS
