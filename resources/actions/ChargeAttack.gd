extends ActionLeaf
class_name ChargeAttack

enum ChargeState {
	WINDUP,
	CHARGING,
	RECOVERY
}

@export var charge_speed: float = 300.0
@export var charge_distance: float = 200.0
@export var windup_time: float = 0.6
@export var recovery_time: float = 0.4

var current_state: ChargeState = ChargeState.WINDUP
var state_timer: float = 0.0
var start_pos: Vector2
var charge_direction: Vector2

func tick(actor: Node, _blackboard: Blackboard) -> int:
	match current_state:
		ChargeState.WINDUP:
			return handle_windup(actor)
		ChargeState.CHARGING:
			return handle_charge(actor)
		ChargeState.RECOVERY:
			return handle_recovery(actor)
	
	return RUNNING

func handle_windup(actor: Node) -> int:
	if state_timer <= 0:
		# Initialize charge
		state_timer = windup_time
		start_pos = actor.global_position
		if actor.target:
			charge_direction = (actor.target.global_position - actor.global_position).normalized()
		else:
			return FAILURE
		
		if actor.sprite:
			actor.sprite.play("charge_windup")
	
	state_timer -= get_physics_process_delta_time()
	if state_timer <= 0:
		current_state = ChargeState.CHARGING
	
	return RUNNING

func handle_charge(actor: Node) -> int:
	if actor.sprite:
		actor.sprite.play("charge")
		actor.sprite.flip_h = charge_direction.x < 0
	
	# Move with charge speed
	actor.velocity = charge_direction * charge_speed
	actor.move_and_slide()
	
	# Check if we've charged far enough
	var distance_traveled = actor.global_position.distance_to(start_pos)
	if distance_traveled >= charge_distance:
		enter_recovery(actor)
		return RUNNING
	
	# Check if we hit the player during charge
	if actor.get_distance_to_player() <= actor.attack_range:
		actor.attack_player()
		enter_recovery(actor)
		return RUNNING
	
	return RUNNING

func handle_recovery(actor: Node) -> int:
	if actor.sprite:
		actor.sprite.play("idle")
	
	actor.velocity = Vector2.ZERO
	
	state_timer -= get_physics_process_delta_time()
	if state_timer <= 0:
		reset()
		return SUCCESS
	
	return RUNNING

func enter_recovery(actor: Node) -> void:
	current_state = ChargeState.RECOVERY
	state_timer = recovery_time
	actor.velocity = Vector2.ZERO

func reset() -> void:
	current_state = ChargeState.WINDUP
	state_timer = 0.0
