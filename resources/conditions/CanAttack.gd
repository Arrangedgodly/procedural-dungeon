extends ConditionLeaf
class_name CanAttack

func tick(actor: Node, blackboard: Blackboard) -> int:
	if actor.attack_timer:
		if !actor.attack_timer.is_stopped():
			return FAILURE
		
	if blackboard.get_value("is_attacking"):
		return RUNNING
			
	var distance = actor.get_distance_to_player()
	
	if distance == -1:
		return FAILURE
	
	if distance <= actor.attack_range:
		blackboard.set_value("can_attack", true)
		if actor.debug:
			actor.debug.update_state("CAN ATTACK")
		return SUCCESS
	
	blackboard.set_value("can_attack", false)
	if actor.debug:
			actor.debug.update_state("CAN'T ATTACK")
	return FAILURE
