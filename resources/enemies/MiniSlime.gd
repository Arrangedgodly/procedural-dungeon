extends MeleeEnemy
class_name MiniSlime

const TINY_GROUND_SLAM_EFFECT = preload("res://scenes/effects/tiny_ground_slam.tscn")

func _ready() -> void:
	health = 10
	speed = 75
	damage = 15
	approach_range = 300
	attack_range = 30
	super._ready()

func attack_player() -> void:
	if target and get_distance_to_player() <= attack_range:
		sprite.play("attack")
		await sprite.animation_finished 
		var ground_slam = TINY_GROUND_SLAM_EFFECT.instantiate()
		get_tree().get_first_node_in_group("effects").add_child(ground_slam)
		ground_slam.update_position(get_sprite_content_center())
		if target and get_distance_to_player() <= attack_range:
			target.take_damage(damage)
		attack_timer.start()
