extends CharacterBody2D
class_name Player
signal target_position_changed(pos: Vector2)
signal target_position_reached

@export var sprite: AnimatedSprite2D
@export var collision_shape: CollisionShape2D
@onready var CircleMarker: Node2D

var health: int = 50
var speed: int = 200
var basic_damage: int = 5
var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var current_health: int
var knockback_strength: float = 400.0
var knockback_duration: float = 0.3
var knockback_velocity: Vector2 = Vector2.ZERO
var is_being_knocked_back: bool = false
var knockback_timer: float = 0.0
var knockback_friction: float = 0.8
var bounce_factor: float = 0.5

func _ready() -> void:
	current_health = health

func _physics_process(delta: float) -> void:
	if is_being_knocked_back:
		handle_knockback(delta)
	elif Input.is_action_just_pressed("right-click"):
		target_position = get_global_mouse_position()
		target_position_changed.emit(target_position)
		is_moving = true
		
		if has_node("AnimatedSprite2D"):
			sprite.play("walk")
	
	if is_moving and !is_being_knocked_back:
		var direction = (target_position - global_position).normalized()
		var distance_to_target = global_position.distance_to(target_position)
		
		if distance_to_target < 5:
			is_moving = false
			velocity = Vector2.ZERO
			target_position_reached.emit()
			if has_node("AnimatedSprite2D"):
				sprite.play("idle")
		else:
			velocity = direction * speed
			
			if has_node("AnimatedSprite2D"):
				if direction.x < 0:
					sprite.flip_h = true
				elif direction.x > 0:
					sprite.flip_h = false
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		handle_collision(collision)

func take_damage(damage_taken: int) -> void:
	current_health -= damage_taken

func knock_back(direction: Vector2) -> void:
	# Normalize the direction and apply knockback in the opposite direction
	knockback_velocity = -direction.normalized() * knockback_strength
	is_being_knocked_back = true
	is_moving = false  # Stop normal movement
	knockback_timer = knockback_duration
	
	# Play hit animation if available
	if has_node("AnimatedSprite2D"):
		sprite.play("hit")  # Assuming you have a "hit" animation

func handle_knockback(delta: float) -> void:
	knockback_timer -= delta
	
	if knockback_timer <= 0:
		is_being_knocked_back = false
		knockback_velocity = Vector2.ZERO
		if has_node("AnimatedSprite2D"):
			sprite.play("idle")
		return
	
	# Apply friction to gradually slow down the knockback
	knockback_velocity *= knockback_friction
	velocity = knockback_velocity

func handle_collision(collision: KinematicCollision2D) -> void:
	if is_being_knocked_back:
		# Calculate bounce direction
		var bounce_velocity = knockback_velocity.bounce(collision.get_normal())
		# Apply bounce factor to reduce velocity after bounce
		knockback_velocity = bounce_velocity * bounce_factor
	else:
		# Handle normal movement collision by sliding
		velocity = velocity.slide(collision.get_normal())
