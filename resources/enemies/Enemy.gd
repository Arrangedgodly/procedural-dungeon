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

const DAMAGE_POPUP = preload("res://scenes/damage_popup.tscn")
const HEALTH_PACK = preload("res://scenes/items/pickups/health_pack.tscn")
const EXPERIENCE_GEM = preload("res://scenes/items/pickups/experience_gem.tscn")
const HEALTH_PACK_DROP_CHANCE = 0.05  # 5% chance
const MIN_EXPERIENCE_GEMS = 3
const MAX_EXPERIENCE_GEMS = 7
const GEM_SCATTER_FORCE = 100.0

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
		if event.is_action_pressed("right-click"):
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
	
	self.z_index = 10
	add_to_group("enemies")
	set_target()
	print(self.name + " initialized")

func take_damage(dmg: int) -> void:
	var is_crit = randf() <= 0.2
	if is_crit:
		dmg *= 1.25
	spawn_damage_popup(dmg, "normal", is_crit)
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
	handle_death_drops()
	sprite.play("death")
	set_is_targeted(false)
	sprite.clear_polygons()
	sprite.material = null
	health_bar.hide()
	await sprite.animation_finished
	set_process(false)
	var tween = create_tween()
	tween.tween_property(sprite, "self_modulate", Color(1, 1, 1, 0), 10)
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
	if is_dead:
		CursorManager.set_cursor_with_priority("disabled", self)
	else:
		CursorManager.set_cursor_with_priority("crosshair", self)

func _on_mouse_exited() -> void:
	is_hovered = false
	CursorManager.remove_cursor_source(self)

func get_sprite_content_center() -> Vector2:
	var texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	var image = texture.get_image()
	
	# Find bounds of non-transparent pixels
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := 0
	var max_y := 0
	
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a > 0:  # If pixel is not transparent
				min_x = min(min_x, x)
				min_y = min(min_y, y)
				max_x = max(max_x, x)
				max_y = max(max_y, y)
	
	# Calculate center of actual content
	var center = Vector2(
		(min_x + max_x) / 2.0,
		(min_y + max_y) / 2.0
	)
	
	# Offset from sprite's top-left to this center point
	var offset = center - (Vector2(image.get_width(), image.get_height()) / 2.0)
	
	return sprite.global_position + offset

func spawn_damage_popup(damage: int, type: String = "normal", is_crit: bool = false) -> void:
	var popup = DAMAGE_POPUP.instantiate()
	add_child(popup)
	popup.setup(damage, type, is_crit)

func _exit_tree() -> void:
	CursorManager.remove_cursor_source(self)

func handle_death_drops() -> void:
	var pickups_parent = get_tree().get_first_node_in_group("pickups")
	if !pickups_parent:
		print("No pickup group found")
		return
		
	if randf() <= HEALTH_PACK_DROP_CHANCE:
		spawn_health_pack(pickups_parent)
	
	spawn_experience_gems(pickups_parent)

func spawn_health_pack(parent: Node) -> void:
	var pickups = get_tree().get_first_node_in_group("pickups")
	var health_pack = HEALTH_PACK.instantiate()
	pickups.add_child(health_pack)
	health_pack.global_position = global_position

func spawn_experience_gems(parent: Node) -> void:
	var pickups = get_tree().get_first_node_in_group("pickups")
	var num_gems = randi_range(MIN_EXPERIENCE_GEMS, MAX_EXPERIENCE_GEMS)
	
	for i in range(num_gems):
		var gem = EXPERIENCE_GEM.instantiate()
		pickups.add_child(gem)
		gem.global_position = global_position
		
		var scatter_direction = Vector2.RIGHT.rotated(randf() * TAU)
		var scatter_distance = randf_range(20, 50)
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(gem, "position", 
			gem.position + (scatter_direction * scatter_distance), 0.3)
