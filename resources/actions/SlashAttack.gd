extends ActionLeaf
class_name SlashAttack

enum SlashState {
	WINDUP,
	SLASHING,
	RECOVERY
}

@export var windup_time: float = 0.2
@export var slash_time: float = 0.15
@export var recovery_time: float = 0.3
@export var move_during_slash: bool = true  # Whether to move forward while slashing
@export var slash_movement_speed: float = 150.0  # Speed during slash if moving

var current_state: SlashState = SlashState.WINDUP
var state_timer: float = 0.0
var slash_direction: Vector2

func tick(actor: Node, _blackboard: Blackboard) -> int:
	match current_state:
		SlashState.WINDUP:
			return handle_windup(actor)
		SlashState.SLASHING:
			return handle_slash(actor)
		SlashState.RECOVERY:
			return handle_recovery(actor)
	
	return RUNNING

func handle_windup(actor: Node) -> int:
	if state_timer <= 0:
		# Initialize the slash
		state_timer = windup_time
		if actor.target:
			slash_direction = (actor.target.global_position - actor.global_position).normalized()
		else:
			slash_direction = Vector2.RIGHT if actor.sprite.flip_h else Vector2.LEFT
		
		if actor.sprite:
			actor.sprite.play("attack_windup")
			actor.sprite.flip_h = slash_direction.x < 0
	
	# Hold position during windup
	actor.velocity = Vector2.ZERO
	
	state_timer -= get_physics_process_delta_time()
	if state_timer <= 0:
		current_state = SlashState.SLASHING
		state_timer = slash_time
	
	return RUNNING

func handle_slash(actor: Node) -> int:
	if actor.sprite:
		actor.sprite.play("attack")
	
	# Move during slash if enabled
	if move_during_slash:
		actor.velocity = slash_direction * slash_movement_speed
		actor.move_and_slide()
	else:
		actor.velocity = Vector2.ZERO
	
	# Deal damage if in range during the active slash frames
	if actor.get_distance_to_player() <= actor.attack_range:
		actor.attack_player()
	
	state_timer -= get_physics_process_delta_time()
	if state_timer <= 0:
		current_state = SlashState.RECOVERY
		state_timer = recovery_time
	
	return RUNNING

func handle_recovery(actor: Node) -> int:
	if actor.sprite:
		actor.sprite.play("idle")
	
	# Stop movement during recovery
	actor.velocity = Vector2.ZERO
	
	state_timer -= get_physics_process_delta_time()
	if state_timer <= 0:
		reset()
		return SUCCESS
	
	return RUNNING

func reset() -> void:
	current_state = SlashState.WINDUP
	state_timer = 0.0
