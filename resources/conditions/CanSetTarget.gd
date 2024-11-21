extends ConditionLeaf
class_name CanSetTarget

func tick(actor: Node, blackboard: Node) -> int:
	if blackboard.target:
		return FAILURE
	else:
		return SUCCESS
