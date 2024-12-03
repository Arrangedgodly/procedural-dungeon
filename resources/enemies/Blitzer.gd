extends MeleeEnemy
class_name Blitzer

var direction: Vector2
var is_charging: bool = false
var charge_telegraph: Line2D
var can_damage: bool = true  # Cooldown flag

func _ready() -> void:
	health = 30
	speed = 200
	damage = 75
	approach_range = 1000
	attack_range = 500
	
	charge_telegraph = Line2D.new()
	charge_telegraph.width = 2.0
	charge_telegraph.default_color = Color(1, 0, 0, 0.5)
	add_child(charge_telegraph)
	charge_telegraph.hide()
	
	super._ready()

func attack_player() -> void:
	if is_dead or is_charging or !can_damage:
		return
		
	if !target:
		return
		
	# Start charge sequence
	direction = (target.global_position - global_position).normalized()
	sprite.play("attack")
	sprite.flip_h = direction.x < 0
	charge_telegraph.show()
	update_charge_telegraph()
	
	await get_tree().create_timer(0.5).timeout
	charge_telegraph.hide()
	
	if is_dead or !target:
		return
		
	is_charging = true
	can_damage = true
	velocity = direction * speed * 2
	
	# Set up charge timeout
	get_tree().create_timer(2.0).timeout.connect(end_charge)

func _physics_process(delta: float) -> void:
	if is_charging:
		move_and_slide()
		check_collision()

func check_collision() -> void:
	if !is_charging or !can_damage:
		return
		
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() == target and can_damage:
			target.take_damage(damage)
			can_damage = false  # Prevent multiple hits
			end_charge()
			return
		elif collision.get_collider().is_in_group("walls"):
			end_charge()
			return

func end_charge() -> void:
	is_charging = false
	sprite.play("idle")
	velocity = Vector2.ZERO
	await get_tree().create_timer(1.0).timeout
	can_damage = true
	attack_timer.start()

func update_charge_telegraph() -> void:
	if target:
		direction = (target.global_position - global_position).normalized()
		charge_telegraph.clear_points()
		charge_telegraph.add_point(Vector2.ZERO)
		charge_telegraph.add_point(direction * attack_range)

# TODO: Fix charge attack so the sprite keeps the attack animation playing and the blitzer stops when it hits a wall instead of stupid sliding
