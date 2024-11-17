extends ConditionLeaf
class_name IsEnemyNotInitialized

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if actor.is_initialized:
		return FAILURE
	
	return SUCCESS
