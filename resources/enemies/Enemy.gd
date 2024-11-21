extends CharacterBody2D
class_name Enemy
signal animation_ended

@export var sprite: AnimatedSprite2D
@export var collision_shape: CollisionShape2D
@export var attack_cooldown_timer: Timer
@onready var outline_shader = preload("res://shaders/outline_shader.tres")
@onready var progress_bar = preload("res://scenes/progress_bar.tscn")
var is_initialized: bool = false
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
var is_targeted: bool = false
var is_hovered: bool = false
var outline_width: float = .002
var health_bar
@export var modification_color: Color

func init() -> void:
	target = get_tree().get_first_node_in_group("player")
	if target:
		target.died.connect(remove_target)
		
	current_health = health
	
	if modification_color:
		sprite.self_modulate = modification_color
	sprite.material = outline_shader
	sprite.material.set_shader_parameter("width", 0)
	var sprite_frame = sprite.sprite_frames.get_frame_texture("idle", 0)
	
	health_bar = progress_bar.instantiate()
	add_child(health_bar)
	health_bar.scale = Vector2(.125, .125)
	health_bar.position.x -= sprite_frame.get_width() / 2
	health_bar.position.y += sprite_frame.get_height() - 10
	health_bar.init(health)
	health_bar.hide()
	
	input_pickable = true
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	
	add_to_group("enemies")
	
	is_initialized = true
	print(self.name + " initialized")

func _process(_delta: float) -> void:
	if target != null and target.health == 0:
		remove_target()

func _input(event: InputEvent) -> void:
	if is_hovered:
		if event.is_action_pressed("click"):
			set_is_targeted(true)
	
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
	health_bar.show()
	current_health -= dmg
	health_bar.set_progress_value(current_health)
	is_hit = true

func reset_hit_state() -> void:
	is_hit = false
	is_playing_hit = false
	sprite.animation_finished.disconnect(reset_hit_state)

func reset_attack_state() -> void:
	can_attack = true
	sprite.animation_finished.disconnect(reset_attack_state)

func remove_corpse():
	set_is_targeted(false)
	collision_shape.disabled = true
	health_bar.hide()
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0, 10)
	await tween.finished
	self.queue_free()

func remove_target():
	target = null

func set_is_targeted(value: bool) -> void:
	if value and target:
		target.target_enemy(self)
		
	is_targeted = value
	if sprite.material:
		sprite.material.set_shader_parameter("width", outline_width if value else 0.0)

func _on_mouse_entered() -> void:
	is_hovered = true

func _on_mouse_exited() -> void:
	is_hovered = false
