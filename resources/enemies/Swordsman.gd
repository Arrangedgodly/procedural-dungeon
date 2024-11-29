extends MeleeEnemy
class_name Swordsman

const SLASH_EFFECT = preload("res://scenes/effects/slash.tscn")

func _ready() -> void:
	health = 40
	speed = 150
	damage = 20
	attack_range = 25
	approach_range = 250
	super._ready()

func attack_player() -> void:
	if is_dead or !target:
		return
		
	var attack_dir = (target.global_position - global_position).normalized()
	sprite.flip_h = attack_dir.x < 0
	
	sprite.play("attack")
	
	# First downward slash
	var down_slash = create_slash_effect(false)
	check_slash_hit(down_slash.global_position)
	
	# Wait briefly then do upward slash
	await get_tree().create_timer(0.15).timeout
	var up_slash = create_slash_effect(true)
	check_slash_hit(up_slash.global_position)
	
	attack_timer.start()

func create_slash_effect(flip_vertical: bool) -> Node2D:
	var slash = SLASH_EFFECT.instantiate()
	get_tree().get_first_node_in_group("effects").add_child(slash)
	
	if target:
		var attack_dir = (target.global_position - global_position).normalized()
		var offset_distance = 15
		
		slash.global_position = get_sprite_content_center() + (attack_dir * offset_distance)
		slash.rotation = attack_dir.angle() - PI/2
		slash.flip_v = true if flip_vertical else false
	
	return slash

func check_slash_hit(slash_position: Vector2) -> void:
	if target and target.global_position.distance_to(slash_position) <= 30:
		target.take_damage(damage)
