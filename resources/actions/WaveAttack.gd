extends BaseRangedAttackAction
class_name WaveAttack

@export var wave_width: float = PI/2  # 90 degrees
@export var num_waves: int = 3
@export var projectiles_per_wave: int = 8
var current_wave: int = 0
var wave_timer: float = 0.0
@export var wave_delay: float = 0.2

func perform_attack(_actor: Node, _blackboard: Blackboard) -> int:
	if current_wave >= num_waves:
		current_wave = 0
		return SUCCESS
		
	if wave_timer > 0:
		wave_timer -= get_physics_process_delta_time()
		return RUNNING
		
	var base_direction = actor.global_position.direction_to(actor.target.global_position)
	var angle_step = wave_width / (projectiles_per_wave - 1)
	var start_angle = -wave_width/2
	
	for i in range(projectiles_per_wave):
		var direction = base_direction.rotated(start_angle + i * angle_step)
		spawn_projectile(direction)
	
	current_wave += 1
	wave_timer = wave_delay
	
	return RUNNING
