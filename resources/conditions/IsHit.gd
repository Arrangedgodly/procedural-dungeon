extends ConditionLeaf
class_name IsHit

func tick(actor: Node, blackboard: Node) -> int:
	if blackboard.get_value("playing_hit"):
		return RUNNING
		
	if actor.is_hit:
		return SUCCESS
		
	return FAILURE
