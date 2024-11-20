extends ActionLeaf
class_name PlayHit

func tick(actor: Node, _blackboard: Node) -> int:
	if actor.sprite and !actor.is_playing_hit:
		actor.is_playing_hit = true
		actor.sprite.play("hurt")
		
		actor.sprite.animation_finished.connect(actor.reset_hit_state)
		
		return SUCCESS
	
	return FAILURE
