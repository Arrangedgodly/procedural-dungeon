extends MeleeEnemy
class_name MediumSlime

const MINI_SLIME = preload("res://scenes/enemies/mini_slime.tscn")
var min_splits: int = 2
var max_splits: int = 6

func _ready() -> void:
	health = 50
	speed = 50
	damage = 15
	super._ready()

func attack_player() -> void:
	if target and get_distance_to_player() <= attack_range:
		sprite.play("attack")
		if target:
			target.take_damage(damage)

func remove_corpse() -> void:
	var num_slimes = randi_range(min_splits, max_splits)
	for i in num_slimes:
		var mini_slime = MINI_SLIME.instantiate()
		mini_slime.global_position = global_position
		var random_offset = Vector2(
			randf_range(-20, 20),
			randf_range(-20, 20)
		)
		mini_slime.global_position += random_offset
		var random_direction = Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		).normalized()
		mini_slime.velocity = random_direction * 100
		get_parent().add_child(mini_slime)
	super.remove_corpse()
