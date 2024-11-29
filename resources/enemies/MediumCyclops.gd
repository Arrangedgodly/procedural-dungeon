extends MeleeEnemy
class_name MediumCyclops

const QUICK_SLAM_EFFECT = preload("res://scenes/effects/quick_slam.tscn")

var slam_count: int = 0
var max_slams: int = 3
var is_attacking: bool = false
var base_slam_radius: float = 50.0
var slam_growth_factor: float = 1.5

func _ready() -> void:
	health = 200
	speed = 200
	damage = 30
	attack_range = 40
	approach_range = 300
	super._ready()

func attack_player() -> void:
	if is_dead or is_attacking:
		return
		
	is_attacking = true
	slam_count = 0
	perform_slam_combo()

func perform_slam_combo() -> void:
	if slam_count < max_slams and !is_dead and target:
		# Calculate growing slam size
		var current_slam_size = base_slam_radius * pow(slam_growth_factor, slam_count)
		
		sprite.play("attack")
		await sprite.animation_finished
		
		var slam = QUICK_SLAM_EFFECT.instantiate()
		get_tree().get_first_node_in_group("effects").add_child(slam)
		slam.global_position = get_sprite_content_center()
		
		# Scale the visual effect based on slam size
		var scale_factor = current_slam_size / base_slam_radius
		slam.scale = Vector2(scale_factor, scale_factor)
		
		# Check for players in growing slam radius
		if target and get_distance_to_player() <= current_slam_size:
			var slam_damage = damage * (1.0 + (slam_count * 0.5))  # Increasing damage with each slam
			target.take_damage(slam_damage)
		
		slam_count += 1
		
		# Brief pause between slams that gets shorter with each slam
		var delay = max(0.1, 0.4 - (slam_count * 0.5))  # Starts at 0.4s, gets faster
		await get_tree().create_timer(delay).timeout
		perform_slam_combo()
	else:
		# Reset after combo ends
		is_attacking = false
		velocity = Vector2.ZERO
		attack_timer.start()
