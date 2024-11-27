extends ConditionLeaf
class_name IsPlayerNotInApproachRange

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var distance_from_player = actor.get_distance_to_player()
	
	if distance_from_player > actor.approach_range:
		if actor.debug:
			actor.debug.update_state("WANDERING")
		return SUCCESS
	else:
		return FAILURE
