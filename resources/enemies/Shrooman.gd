extends RangedEnemy
class_name Shrooman

const WARNING_EFFECT = preload("res://scenes/effects/warning.tscn")
const EXPLOSION_EFFECT = preload("res://scenes/effects/explosion.tscn")

var explosion_radius: float = 40.0
var num_explosions: int = 3
var current_explosion: int = 0
var is_attacking: bool = false

func _ready() -> void:
	health = 25
	speed = 200
	damage = 75
	approach_range = 400
	attack_range = 200
	super._ready()

func attack_player() -> void:
	if is_dead or is_attacking:
		return
	
	is_attacking = true
	sprite.play("attack")
	current_explosion = 0
	
	create_explosion_sequence()

func create_explosion_sequence() -> void:
	if current_explosion < num_explosions and !is_dead and target:
		create_explosion()
		current_explosion += 1
		
		if current_explosion < num_explosions:
			await get_tree().create_timer(0.5).timeout
			create_explosion_sequence()
		else:
			finish_attack()

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
	
	# Wait and create explosion
	await get_tree().create_timer(1.5).timeout
	if is_dead or !target:
		warning.queue_free()
		finish_attack()
		return
		
	warning.queue_free()
	var explosion = EXPLOSION_EFFECT.instantiate()
	var explosion_frame = explosion.sprite_frames.get_frame_texture("default", 0)
	explosion_radius = explosion_frame.get_width()
	get_parent().add_child(explosion)
	explosion.global_position = explosion_pos
	
	if target and explosion_pos.distance_to(target.global_position) < explosion_radius:
		target.take_damage(damage)

func finish_attack() -> void:
	is_attacking = false
	attack_timer.start()
		
	if !is_attacking:
		attack_player()

func take_damage(dmg: int) -> void:
	super.take_damage(dmg)
	if is_attacking:
		is_attacking = false
