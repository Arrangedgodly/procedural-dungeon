extends ActionLeaf
class_name AttackPlayer

func tick(actor: Node, blackboard: Blackboard) -> int:
	if blackboard.get_value("is_attacking"):
		return RUNNING
		
	if !blackboard.get_value("can_attack"):
		return FAILURE
	
	if actor.target:
		if actor.keep_distance:
			# Ranged enemy logic
			var distance = actor.get_distance_to_player()
			if distance < actor.attack_range:
				if actor.debug:
					actor.debug.update_state("RETREATING")
				var direction = (actor.target.global_position - actor.global_position).normalized()
				actor.velocity = -direction * actor.speed
				actor.move_and_slide()
			else:
				initiate_attack(actor, blackboard)
		else:
			# Melee enemy logic
			initiate_attack(actor, blackboard)
	
	return SUCCESS

func initiate_attack(actor: Node, blackboard: Blackboard) -> void:
	actor.velocity = Vector2.ZERO
	set_is_attacking(actor, blackboard, true)
	actor.attack_player()
	actor.sprite.play("attack")
	if !actor.sprite.animation_finished.is_connected(change_actor_animation):
		actor.sprite.animation_finished.connect(change_actor_animation.bind(actor, blackboard))
	actor.attack_timer.start()
	actor.attack_timer.timeout.connect(set_is_attacking.bind(actor, blackboard, false))

func change_actor_animation(actor: Node, blackboard: Node) -> void:
	set_is_attacking(actor, blackboard, false)
	if actor.debug:
			actor.debug.update_state("ATTACK COOLDOWN")
	actor.sprite.play("idle")
	actor.sprite.animation_finished.disconnect(change_actor_animation)

func set_is_attacking(actor: Node, blackboard: Node, value: bool) -> void:
	blackboard.set_value("is_attacking", value)
	if actor.debug:
			actor.debug.update_state("ATTACKING")
	if actor.attack_timer.timeout.is_connected(set_is_attacking):
		actor.attack_timer.timeout.disconnect(set_is_attacking)
