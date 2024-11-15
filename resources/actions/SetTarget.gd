extends ActionLeaf
class_name SetTarget

func tick(actor: Node, _blackboard: Node) -> int:
	var player = get_tree().get_first_node_in_group("player")
	actor.target = player
	
	return SUCCESS
