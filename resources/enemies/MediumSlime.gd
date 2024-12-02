extends MeleeEnemy
class_name MediumSlime

const MINI_SLIME_PATH: String = "res://scenes/enemies/mini_slime.tscn"
const GROUND_SLAM_EFFECT = preload("res://scenes/effects/ground_slam.tscn")
var min_splits: int = 2
var max_splits: int = 6

func _ready() -> void:
	health = 50
	speed = 50
	damage = 65
	attack_range = 50
	approach_range = 250
	super._ready()

func attack_player() -> void:
	if target and get_distance_to_player() <= attack_range:
		sprite.play("attack")
		await sprite.animation_finished 
		var ground_slam = GROUND_SLAM_EFFECT.instantiate()
		get_tree().get_first_node_in_group("effects").add_child(ground_slam)
		ground_slam.update_position(get_sprite_content_center())
		if target and get_distance_to_player() <= attack_range:
			target.take_damage(damage)
		attack_timer.start()

func remove_corpse() -> void:
	super.remove_corpse()
	
	var num_slimes = randi_range(min_splits, max_splits)
	for i in num_slimes:
		var mini_slime = EnemyManager.instantiate_enemy_by_path(MINI_SLIME_PATH)
		get_parent().add_child(mini_slime)
		mini_slime.global_position = global_position
		var random_offset = Vector2(
			randf_range(-50, 50),
			randf_range(-50, 50)
		)
		mini_slime.global_position += random_offset
		var random_direction = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		).normalized()
		mini_slime.velocity = random_direction * 100
