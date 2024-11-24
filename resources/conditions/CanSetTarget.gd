extends ConditionLeaf
class_name CanSetTarget

func tick(_actor: Node, blackboard: Node) -> int:
	if blackboard.get_value("target"):
		return FAILURE
	else:
		return SUCCESS
