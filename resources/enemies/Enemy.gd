extends CharacterBody2D
class_name Enemy
signal animation_ended

@export var sprite: AnimatedSprite2D
@export var collision_shape: CollisionShape2D
@export var attack_cooldown_timer: Timer
@onready var outline_shader = preload("res://shaders/outline_shader.tres")
@onready var progress_bar = preload("res://scenes/progress_bar.tscn")
@onready var click_area: Area2D
@onready var click_collision: CollisionShape2D
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
var attack_cooldown: float = 1.0
var is_targeted: bool = false
var outline_width: float = .002

func init() -> void:
	target = get_tree().get_first_node_in_group("player")
	if target:
		target.died.connect(remove_target)
		
	current_health = health
	
	sprite.material = outline_shader
	sprite.material.set_shader_parameter("width", 0)
	var sprite_frame = sprite.sprite_frames.get_frame_texture("idle", 0)
	
	var health_bar = progress_bar.instantiate()
	add_child(health_bar)
	health_bar.set_background_color(Color(1, .5, .25, 1))
	health_bar.set_under_color(Color(1, 1, 1, 1))
	health_bar.set_progress_color(Color(1, 0, 0, 1))
	health_bar.set_colors()
	health_bar.scale = Vector2(.05, .05)
	health_bar.position.x -= 6
	health_bar.position.y += sprite_frame.get_height()
	health_bar.init(health)
	
	collision_shape.disabled = false
	set_collision_layer_value(2, true)
	set_collision_mask_value(1, true)
	
	click_area = Area2D.new()
	add_child(click_area)
	click_collision = CollisionShape2D.new()
	click_collision.shape = CircleShape2D.new()
	click_collision.shape.radius = sprite_frame.get_width() / 2
	click_area.add_child(click_collision)
	click_area.input_event.connect(_on_click_area_input_event)
	click_collision.debug_color = Color(0, 1, 0, 0.3)
	click_collision.set_deferred("debug_draw", true)
	
	add_to_group("enemies")
	
	is_initialized = true

func _process(_delta: float) -> void:
	if target != null and target.health == 0:
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

func set_is_targeted(value: bool) -> void:
	is_targeted = value
	if sprite.material:
		sprite.material.set_shader_parameter("width", outline_width if value else 0.0)

func _on_click_area_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		set_is_targeted(true)
