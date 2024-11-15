extends ConditionLeaf
class_name CanAttack

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var distance_from_player = actor.get_distance_to_player()
	
	if distance_from_player == -1:
		return FAILURE
	
	if distance_from_player <= actor.attack_range:
		return SUCCESS
	else:
		return FAILURE
