extends ActionLeaf
class_name BurstRangedAttack

enum BurstState { WINDUP, SHOOTING, RECOVERY }

@export var projectile_scene: PackedScene
@export var bullets_per_burst: int = 3
@export var burst_delay: float = 0.2
@export var windup_time: float = 0.3
@export var recovery_time: float = 0.5

var current_state: BurstState = BurstState.WINDUP
var state_timer: float = 0.0
var bullets_fired: int = 0

func tick(actor: Node, _blackboard: Blackboard) -> int:
	match current_state:
		BurstState.WINDUP:
			return handle_windup(actor)
		BurstState.SHOOTING:
			return handle_shooting(actor)
		BurstState.RECOVERY:
			return handle_recovery(actor)
	
	return RUNNING

func handle_windup(actor: Node) -> int:
	if state_timer <= 0:
		state_timer = windup_time
		if actor.sprite:
			actor.sprite.play("attack_windup")
	
	state_timer -= get_physics_process_delta_time()
	if state_timer <= 0:
		current_state = BurstState.SHOOTING
		state_timer = burst_delay
	
	return RUNNING

func handle_shooting(actor: Node) -> int:
	state_timer -= get_physics_process_delta_time()
	
	if state_timer <= 0 and bullets_fired < bullets_per_burst:
		if actor.sprite:
			actor.sprite.play("attack")
			
		spawn_projectile(actor)
		bullets_fired += 1
		state_timer = burst_delay
		
	if bullets_fired >= bullets_per_burst:
		current_state = BurstState.RECOVERY
		state_timer = recovery_time
		
	return RUNNING

func handle_recovery(actor: Node) -> int:
	if actor.sprite:
		actor.sprite.play("idle")
		
	state_timer -= get_physics_process_delta_time()
	if state_timer <= 0:
		reset()
		return SUCCESS
		
	return RUNNING

func reset() -> void:
	current_state = BurstState.WINDUP
	state_timer = 0.0
	bullets_fired = 0

func spawn_projectile(actor: Node) -> void:
	var projectile = projectile_scene.instantiate()
	actor.get_parent().add_child(projectile)
	projectile.global_position = actor.global_position
	if actor.target:
		projectile.launch(actor.target.global_position)
