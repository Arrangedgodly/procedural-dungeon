extends ActionLeaf
class_name ComboAttack

enum ComboState {
	WINDUP,
	ATTACKING,
	RECOVERY
}

@export var combo_data: Array[Dictionary] = [
	{ 
		"windup_time": 0.2,
		"attack_time": 0.2,
		"recovery_time": 0.3,
		"damage": 1
	},
	{
		"windup_time": 0.3,
		"attack_time": 0.2,
		"recovery_time": 0.3,
		"damage": 2
	},
	{
		"windup_time": 0.4,
		"attack_time": 0.3,
		"recovery_time": 0.4,
		"damage": 3
	}
]

var current_combo: int = 0
var current_state: ComboState = ComboState.WINDUP
var state_timer: float = 0.0
var combo_window_timer: float = 0.0
@export var combo_window: float = 0.8

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if combo_window_timer > 0:
		combo_window_timer -= get_physics_process_delta_time()
		if combo_window_timer <= 0:
			reset_combo()
	
	match current_state:
		ComboState.WINDUP:
			return handle_windup(actor)
		ComboState.ATTACKING:
			return handle_attack(actor)
		ComboState.RECOVERY:
			return handle_recovery(actor)
	
	return RUNNING

func handle_windup(actor: Node) -> int:
	if state_timer <= 0:
		# Start windup
		var attack = combo_data[current_combo]
		state_timer = attack.windup_time
		if actor.sprite:
			actor.sprite.play("attack_windup")
	
	state_timer -= get_physics_process_delta_time()
	if state_timer <= 0:
		current_state = ComboState.ATTACKING
		state_timer = combo_data[current_combo].attack_time
		return RUNNING
	
	return RUNNING

func handle_attack(actor: Node) -> int:
	if actor.sprite:
		actor.sprite.play("attack")
	
	state_timer -= get_physics_process_delta_time()
	if state_timer <= 0:
		actor.attack_player()  # Your existing attack method
		current_state = ComboState.RECOVERY
		state_timer = combo_data[current_combo].recovery_time
		
		# Set combo window for next attack
		combo_window_timer = combo_window
		
		# Move to next combo if available
		current_combo = (current_combo + 1) % combo_data.size()
	
	return RUNNING

func handle_recovery(actor: Node) -> int:
	if actor.sprite:
		actor.sprite.play("idle")
	
	state_timer -= get_physics_process_delta_time()
	if state_timer <= 0:
		current_state = ComboState.WINDUP
		return SUCCESS
	
	return RUNNING

func reset_combo() -> void:
	current_combo = 0
	current_state = ComboState.WINDUP
	combo_window_timer = 0.0
