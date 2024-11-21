extends ActionLeaf
class_name SpinAttack

enum SpinState {
	WINDUP,
	SPINNING,
	RECOVERY
}

@export var spin_duration: float = 1.0
@export var windup_time: float = 0.4
@export var recovery_time: float = 0.5
@export var damage_frequency: float = 0.2
@export var spin_range: float = 100.0

var current_state: SpinState = SpinState.WINDUP
var state_timer: float = 0.0
var damage_timer: float = 0.0
var current_rotation: float = 0.0

func tick(actor: Node, _blackboard: Blackboard) -> int:
	match current_state:
		SpinState.WINDUP:
			return handle_windup(actor)
		SpinState.SPINNING:
			return handle_spin(actor)
		SpinState.RECOVERY:
			return handle_recovery(actor)
	
	return RUNNING

func handle_windup(actor: Node) -> int:
	if state_timer <= 0:
		state_timer = windup_time
		if actor.sprite:
			actor.sprite.play("spin_windup")
	
	state_timer -= get_physics_process_delta_time()
	if state_timer <= 0:
		current_state = SpinState.SPINNING
		state_timer = spin_duration
		damage_timer = 0.0
	
	return RUNNING

func handle_spin(actor: Node) -> int:
	if actor.sprite:
		actor.sprite.play("spin")
	
	state_timer -= get_physics_process_delta_time()
	damage_timer -= get_physics_process_delta_time()
	
	# Update rotation
	current_rotation += 10 * get_physics_process_delta_time()
	if actor.sprite:
		actor.sprite.rotation = current_rotation
	
	# Check for damage intervals
	if damage_timer <= 0:
		check_spin_damage(actor)
		damage_timer = damage_frequency
	
	if state_timer <= 0:
		enter_recovery(actor)
	
	return RUNNING

func handle_recovery(actor: Node) -> int:
	if actor.sprite:
		actor.sprite.play("idle")
		actor.sprite.rotation = 0
	
	state_timer -= get_physics_process_delta_time()
	if state_timer <= 0:
		reset()
		return SUCCESS
	
	return RUNNING

func check_spin_damage(actor: Node) -> void:
	# If player is in range, damage them
	if actor.get_distance_to_player() <= spin_range:
		actor.attack_player()

func enter_recovery(actor: Node) -> void:
	current_state = SpinState.RECOVERY
	state_timer = recovery_time
	if actor.sprite:
		actor.sprite.rotation = 0

func reset() -> void:
	current_state = SpinState.WINDUP
	state_timer = 0.0
	current_rotation = 0.0
