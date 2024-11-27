extends ConditionLeaf
class_name IsDead

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.is_dead:
		if actor.debug:
			actor.debug.update_state("DEAD")
		return SUCCESS
	else:
		return FAILURE
