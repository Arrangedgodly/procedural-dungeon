extends ConditionLeaf
class_name IsPlayerInApproachRange

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var distance_from_player = actor.get_distance_to_player()

	if distance_from_player <= actor.approach_range and distance_from_player > actor.attack_range:
		if actor.debug:
			actor.debug.update_state("APPROACHING")
		return SUCCESS
	else:
		return FAILURE
