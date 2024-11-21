extends ActionLeaf
class_name AttackPlayer

func tick(actor: Node, blackboard: Blackboard) -> int:
	if !blackboard.get_value("can_attack"):
		return FAILURE
	
	if actor.is_attacking:
		return RUNNING
		
	actor.attack_player()
		
	return SUCCESS
