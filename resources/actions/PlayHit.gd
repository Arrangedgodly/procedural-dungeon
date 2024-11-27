extends ActionLeaf
class_name PlayHit

func tick(actor: Node, blackboard: Node) -> int:
	if blackboard.get_value("playing_hit"):
		return RUNNING
		
	if actor.is_hit:
		blackboard.set_value("playing_hit", true)
		if actor.debug:
			actor.debug.update_state("IS HURT")
		actor.sprite.play("hurt")
		
		actor.sprite.animation_finished.connect(reset_hit_state.bind(actor, blackboard))
		
		return SUCCESS
	
	return FAILURE

func reset_hit_state(actor: Node, blackboard: Node) -> void:
	actor.is_hit = false
	blackboard.set_value("playing_hit", false)
	if actor.debug:
			actor.debug.update_state("HURT FINISHED")
	actor.sprite.animation_finished.disconnect(reset_hit_state)
