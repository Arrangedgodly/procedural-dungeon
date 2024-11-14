extends ConditionLeaf
class_name IsDying

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.current_health == 0:
		if actor.is_dead:
			return FAILURE
		return SUCCESS
	else:
		return FAILURE
