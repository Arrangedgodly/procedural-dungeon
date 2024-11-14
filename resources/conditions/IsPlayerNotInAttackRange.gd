extends ConditionLeaf
class_name IsPlayerNotInAttackRange

func tick(actor: Node, _blackboard: Blackboard) -> int:
	var distance_from_player = actor.get_distance_from_player()
	var enemy_attack_range = actor.get_attack_range()

	if distance_from_player > enemy_attack_range:
		return SUCCESS
	else:
		return FAILURE
