extends CharacterBody2D
class_name Enemy
signal animation_ended

@export var sprite: AnimatedSprite2D
@export var collision_shape: CollisionShape2D
var health: int
var speed: int
var damage: int
var attack_range: int = 100
var signal_connected: bool = false
var target
var current_health: int
var is_dead: bool = false

func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	current_health = health
	
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

func get_distance_to_player() -> int:
	if target:
		var distance = self.position.distance_to(target.position)
		return distance
	else:
		return -1
	
func get_attack_range() -> int:
	return attack_range
	
func get_current_health() -> int:
	return current_health

func take_damage(dmg: int):
	current_health -= dmg
