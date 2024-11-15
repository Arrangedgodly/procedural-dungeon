extends ConditionLeaf
class_name IsHit

func tick(actor: Node, _blackboard: Node) -> int:
	if actor.is_hit and !actor.is_playing_hit:
		return SUCCESS
	return FAILURE
