extends ActionLeaf
class_name AttackPlayer

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.sprite:
		actor.sprite.play("attack")
		
	return SUCCESS
