extends CharacterBody2D
class_name Enemy
signal animation_ended

@export var health: int
@export var speed: int
@export var damage: int

@export var sprite: AnimatedSprite2D
@export var collision_shape: CollisionShape2D

var signal_connected: bool = false
	
func animate_enemy() -> void:
	if !signal_connected:
		self.animation_ended.connect(_on_animation_ended)
		signal_connected = true
	sprite.play("attack")
	await sprite.animation_finished
	sprite.play("walk")
	await sprite.animation_looped
	animation_ended.emit()

func _on_animation_ended():
	animate_enemy()
