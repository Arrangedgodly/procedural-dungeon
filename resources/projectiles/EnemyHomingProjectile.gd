extends EnemyProjectile
class_name EnemyHomingProjectile

@export var turn_rate: float = 3
@export var homing_strength: float = 0.85
@export var detection_range: float = 150.0

var target: Node2D
var initial_direction: Vector2

func _ready() -> void:
	super._ready()
	initial_direction = direction

func launch(to_position: Vector2) -> void:
	super.launch(to_position)
	initial_direction = direction

func _process(delta: float) -> void:
	if target and is_instance_valid(target):
		var distance_to_target = global_position.distance_to(target.global_position)
		
		if distance_to_target <= detection_range:
			var desired_direction = (target.global_position - global_position).normalized()
			
			var turn_amount = turn_rate * delta
			direction = direction.lerp(desired_direction, turn_amount * homing_strength)
			
			rotation = direction.angle()
		else:
			direction = direction.lerp(initial_direction, turn_rate * delta * 0.5)
	
	position += direction * speed * delta

func set_target(new_target: Node2D) -> void:
	target = new_target
