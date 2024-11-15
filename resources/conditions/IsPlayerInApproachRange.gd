extends ConditionLeaf
class_name IsPlayerInApproachRange

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var distance_from_player = actor.get_distance_to_player()

	if distance_from_player <= actor.approach_range:
		return SUCCESS
	else:
		return FAILURE
