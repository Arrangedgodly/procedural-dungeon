extends ActionLeaf
class_name RemoveCorpse

func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("started_removal"):
		return RUNNING
		
	actor.remove_corpse()
	blackboard.set_value("started_removal", true)
	
	return SUCCESS
