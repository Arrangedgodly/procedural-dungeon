extends CharacterBody2D
class_name Enemy
signal animation_ended

@export var sprite: AnimatedSprite2D
@export var collision_shape: CollisionShape2D
@onready var outline_shader = preload("res://shaders/outline_shader.tres")
@onready var progress_bar = preload("res://scenes/progress_bar.tscn")
var health: int
var speed: int
var damage: int
var attack_range: int = 25
var approach_range: int = 150
var signal_connected: bool = false
var target
var current_health: int = 1
var is_dead: bool = false
var is_hit: bool = false
var is_playing_hit: bool = false
var can_attack: bool = true
var attack_cooldown: float = 1.0
var is_targeted: bool = false

func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	target.died.connect(remove_target)
	current_health = health
	
	sprite.material = outline_shader
	
	var health_bar = progress_bar.instantiate()
	add_child(health_bar)
	health_bar.scale = 0.05
	health_bar.position += Vector2(-6, -11)

func _process(_delta: float) -> void:
	if target and target.health == 0:
		remove_target()
	
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
	if target and target != null:
		var distance = self.position.distance_to(target.position)
		return distance
	else:
		return -1

func take_damage(dmg: int):
	current_health -= dmg
	is_hit = true

func reset_hit_state() -> void:
	is_hit = false
	is_playing_hit = false

func remove_corpse():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 10)
	await tween.finished
	self.queue_free()

func remove_target():
	target = null
