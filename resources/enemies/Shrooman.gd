extends RangedEnemy
class_name Shrooman

const WARNING_EFFECT = preload("res://scenes/effects/warning.tscn")
const EXPLOSION_EFFECT = preload("res://scenes/effects/explosion.tscn")

var explosion_radius: float = 40.0
var num_explosions: int = 3

func _ready() -> void:
	health = 25
	speed = 200
	damage = 75
	approach_range = 400
	attack_range = 200
	super._ready()

func attack_player() -> void:
	if is_dead:
		return
	
	for i in num_explosions:
		create_explosion()
		await get_tree().create_timer(.5).timeout

func create_explosion() -> void:
	var random_offset = Vector2(
		randf_range(-100, 100),
		randf_range(-100, 100)
	)
	var explosion_pos = target.global_position + random_offset
	
	# Create warning marker
	var warning = WARNING_EFFECT.instantiate()
	get_parent().add_child(warning)
	warning.global_position = explosion_pos
	await get_tree().create_timer(1.5).timeout
	warning.queue_free()
	var explosion = EXPLOSION_EFFECT.instantiate()
	var explosion_frame = explosion.sprite_frames.get_frame_texture("default", 0)
	explosion_radius = explosion_frame.get_width()
	get_parent().add_child(explosion)
	explosion.global_position = explosion_pos
	
	if target:
		if explosion_pos.distance_to(target.global_position) < explosion_radius:
			target.take_damage(damage)
