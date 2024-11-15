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

func _ready() -> void:
	current_health = health

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("right-click"):
		target_position = get_global_mouse_position()
		target_position_changed.emit(target_position)
		is_moving = true
		
		if has_node("AnimatedSprite2D"):
			sprite.play("walk")
	
	if is_moving:
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
	
	move_and_slide()

func take_damage(damage_taken: int) -> void:
	current_health -= damage_taken
