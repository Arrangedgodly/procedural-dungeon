extends ActionLeaf
class_name CactriAttack

const SPIKE = preload("res://scenes/projectiles/spike.tscn")

func tick(actor: Node, _blackboard: Node) -> int:
	if actor.is_dead or !actor.can_attack or !actor.target or !actor.attack_cooldown_timer.is_stopped():
		return FAILURE
	
	if actor.is_attacking:
		return RUNNING
		
	actor.is_attacking = true
	actor.sprite.play("attack")
	
	var spike_distance = 8.0
	var directions = [Vector2.UP, Vector2.LEFT, Vector2.RIGHT]
	
	var projectiles_node = actor.get_tree().get_first_node_in_group("projectiles")
	for dir in directions:
		var spike = SPIKE.instantiate()
		spike.set_damage(actor.damage)
		spike.speed = spike_distance * 10
		projectiles_node.add_child(spike)
		spike.global_position = actor.global_position
		spike.launch(actor.global_position + dir * spike_distance)
	
	actor.attack_cooldown_timer.start()
	
	if !actor.sprite.animation_finished.is_connected(reset_attack_state):
		actor.sprite.animation_finished.connect(reset_attack_state.bind(actor))
	
	return SUCCESS

func reset_attack_state(actor: Node) -> void:
	actor.is_attacking = false
	actor.sprite.animation_finished.disconnect(reset_attack_state)
