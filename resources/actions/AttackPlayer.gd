extends ActionLeaf
class_name AttackPlayer

func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("is_attacking"):
		return RUNNING
		
	if !blackboard.get_value("can_attack"):
		return FAILURE
	
	blackboard.set_value("is_attacking", true)
	actor.attack_player()
	actor.sprite.play("attack")
	actor.sprite.animation_finished.connect(change_actor_animation.bind(actor, blackboard))
	var attacking_timer = get_tree().create_timer(actor.attack_cooldown)
	attacking_timer.timeout.connect(reset_attack_state.bind(blackboard))
		
	return SUCCESS

func reset_attack_state(blackboard: Node):
	blackboard.set_value("is_attacking", true)

func change_actor_animation(actor: Node, blackboard: Node):
	actor.sprite.play("idle")
	actor.sprite.animation_finished.disconnect(change_actor_animation)
