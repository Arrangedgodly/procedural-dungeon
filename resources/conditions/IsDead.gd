extends ConditionLeaf
class_name IsDead

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.is_dead:
		return SUCCESS
	else:
		return FAILURE
