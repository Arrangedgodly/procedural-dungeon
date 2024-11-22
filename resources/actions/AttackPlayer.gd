extends ActionLeaf
class_name AttackPlayer

func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("is_attacking"):
		return RUNNING
		
	if !blackboard.get_value("can_attack"):
		return FAILURE
	
	set_is_attacking(actor, blackboard, true)
	actor.attack_player()
	actor.sprite.play("attack")
	if !actor.sprite.animation_finished.is_connected(change_actor_animation):
		actor.sprite.animation_finished.connect(change_actor_animation.bind(actor, blackboard))
	actor.attack_timer.start()
	actor.attack_timer.timeout.connect(set_is_attacking.bind(actor, blackboard, false))
		
	return SUCCESS

func change_actor_animation(actor: Node, blackboard: Node) -> void:
	set_is_attacking(actor, blackboard, false)
	actor.sprite.play("idle")
	actor.sprite.animation_finished.disconnect(change_actor_animation)

func set_is_attacking(actor: Node, blackboard: Node, value: bool) -> void:
	blackboard.set_value("is_attacking", value)
	if actor.attack_timer.timeout.is_connected(set_is_attacking):
		actor.attack_timer.timeout.disconnect(set_is_attacking)
