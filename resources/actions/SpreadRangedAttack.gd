extends ActionLeaf
class_name SpreadRangedAttack

enum SpreadState { WINDUP, SHOOTING, RECOVERY }

@export var projectile_scene: PackedScene
@export var num_projectiles: int = 5
@export var spread_angle: float = PI/4  # 45 degrees
@export var windup_time: float = 0.4
@export var recovery_time: float = 0.6

var current_state: SpreadState = SpreadState.WINDUP
var state_timer: float = 0.0

func tick(actor: Node, _blackboard: Blackboard) -> int:
	match current_state:
		SpreadState.WINDUP:
			return handle_windup(actor)
		SpreadState.SHOOTING:
			return handle_shooting(actor)
		SpreadState.RECOVERY:
			return handle_recovery(actor)
	
	return RUNNING

func handle_windup(actor: Node) -> int:
	if state_timer <= 0:
		state_timer = windup_time
		if actor.sprite:
			actor.sprite.play("attack_windup")
	
	state_timer -= get_physics_process_delta_time()
	if state_timer <= 0:
		current_state = SpreadState.SHOOTING
	
	return RUNNING

func handle_shooting(actor: Node) -> int:
	if actor.sprite:
		actor.sprite.play("attack")
	
	if actor.target:
		var base_direction = actor.global_position.direction_to(actor.target.global_position)
		var angle_step = spread_angle / (num_projectiles - 1)
		var start_angle = -spread_angle/2
		
		for i in range(num_projectiles):
			var projectile = projectile_scene.instantiate()
			actor.get_parent().add_child(projectile)
			projectile.global_position = actor.global_position
			
			var shot_direction = base_direction.rotated(start_angle + i * angle_step)
			projectile.launch(actor.global_position + shot_direction * 100)
	
	current_state = SpreadState.RECOVERY
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
	current_state = SpreadState.WINDUP
	state_timer = 0.0
