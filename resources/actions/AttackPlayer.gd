extends ActionLeaf
class_name AttackPlayer

func tick(actor: Node, _blackboard: Blackboard) -> int:
	actor.attack_player()
		
	return SUCCESS
