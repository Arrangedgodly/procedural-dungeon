extends ConditionLeaf
class_name CanSetTarget

func tick(actor: Node, _blackboard: Node) -> int:
	if actor.target:
		return FAILURE
	else:
		return SUCCESS
