extends ActionLeaf
class_name InitEnemy

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.init()
	
	return SUCCESS
