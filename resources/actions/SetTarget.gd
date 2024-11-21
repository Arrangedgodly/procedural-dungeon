extends ActionLeaf
class_name SetTarget

func tick(actor: Node, blackboard: Node) -> int:
	actor.set_target()
	if actor.target:
		blackboard.set_value("target", actor.target)
	
	return SUCCESS
