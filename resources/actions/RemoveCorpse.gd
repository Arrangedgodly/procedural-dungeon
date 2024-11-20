extends ActionLeaf
class_name RemoveCorpse

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.remove_corpse()
	
	return RUNNING
