extends ConditionLeaf
class_name CanAttack

func tick(actor: Node, blackboard: Blackboard) -> int:
	var distance = actor.get_distance_to_player()
	
	if distance == -1:
		return FAILURE
	
	if distance <= actor.attack_range:
		blackboard.set_value("can_attack", true)
		return SUCCESS
	
	blackboard.set_value("can_attack", false)
	return FAILURE
