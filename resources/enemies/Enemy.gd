extends CharacterBody2D
class_name Enemy
signal animation_ended

@export var sprite: AnimatedSprite2D
@export var attack_timer: Timer
@onready var outline_shader = preload("res://shaders/outline_shader.tres").duplicate()
@onready var progress_bar = preload("res://scenes/progress_bar.tscn")
@onready var debug_label = preload("res://scenes/enemy_debug_label.tscn")

var health: int
var speed: int
var damage: int
var attack_range: int = 25
var approach_range: int = 150
var target
var current_health: int = 1
var is_dead: bool = false
var is_hit: bool = false
var is_targeted: bool = false
var is_hovered: bool = false
var outline_width: float = .002
var health_bar
@export var modification_color: Color
var keep_distance: bool
var debug

func animate_enemy() -> void:
	if !self.animation_ended.is_connected(animate_enemy):
		self.animation_ended.connect(animate_enemy)
	sprite.play("attack")
	await sprite.animation_finished
	sprite.play("walk")
	await sprite.animation_looped
	animation_ended.emit()
	
func _input(event: InputEvent) -> void:
	if is_hovered:
		if event.is_action_pressed("click"):
			set_is_targeted(true)

func _ready() -> void:	
	current_health = health
	
	if modification_color:
		sprite.self_modulate = modification_color
	sprite.material = outline_shader
	sprite.material.setup_local_to_scene()
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
	
	if OS.is_debug_build():
		debug = debug_label.instantiate()
		add_child(debug)
		debug.init("IDLE", current_health, get_distance_to_player(), speed, damage, attack_range, approach_range)
		if !Debugger.debug_shown:
			debug.hide()
		else:
			debug.show()
	
	add_to_group("enemies")
	set_target()
	print(self.name + " initialized")

func take_damage(dmg: int) -> void:
	health_bar.show()
	current_health -= dmg
	if debug:
		debug.update_health(current_health)
	health_bar.set_progress_value(current_health)
	if current_health <= 0:
		is_dead = true
	else:
		is_hit = true

func attack_player() -> void:
	# Override in child classes
	pass

func remove_corpse() -> void:
	sprite.play("death")
	set_is_targeted(false)
	health_bar.hide()
	await sprite.animation_finished
	set_process(false)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0, 10)
	await tween.finished
	queue_free()

func set_target() -> void:
	target = get_tree().get_first_node_in_group("player")
	if target:
		target.died.connect(remove_target)

func remove_target() -> void:
	target = null

func get_distance_to_player() -> int:
	if target and target != null:
		var distance = self.position.distance_to(target.position)
		if debug:
			debug.update_distance(distance)
		return distance
	else:
		return -1

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
