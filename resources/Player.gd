@icon("res://assets/icons/icon_character.png")
extends CharacterBody2D
class_name Player
signal target_position_changed(pos: Vector2)
signal target_position_reached
signal health_changed(new_health: int)
signal mana_changed(new_mana: int)
signal stamina_changed(new_stamina: int)
signal experience_gained(amount: int)
signal level_up(new_level: int)
signal died

@export var sprite: AnimatedSprite2D
@export var walkable_tiles: TileMapLayer
@onready var stamina_regen: Timer = $StaminaRegen
@onready var basic_attack_timer: Timer = $BasicAttackTimer

var health: int = 500
var speed: int = 200
var stamina: int = 100
var mana: int = 100
var basic_damage: int = 5
var target_position: Vector2 = Vector2.ZERO
var is_moving: bool = false
var current_health: int
var current_stamina: int
var current_mana: int
var is_boosted: bool = false
var is_refreshing: bool = false
var current_target
var is_stopped: bool = false
var stored_target_position: Vector2 = Vector2.ZERO
var has_stored_position: bool = false
var current_experience: int = 0
var current_level: int = 1

const MAGIC_MISSILE = preload("res://scenes/projectiles/magic_missile.tscn")
const DAMAGE_POPUP = preload("res://scenes/damage_popup.tscn")
const HEALING_EFFECT = preload("res://scenes/effects/healing.tscn")
const HEALING_POPUP = preload("res://scenes/healing_popup.tscn")

func _ready() -> void:
	current_health = health
	current_stamina = stamina
	current_mana = mana
	stamina_regen.timeout.connect(_on_stamina_regen_timeout)
	
	self.z_index = 20

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("stop"):
		is_stopped = true
		if is_moving:
			stored_target_position = target_position
			has_stored_position = true
			is_moving = false
			velocity = Vector2.ZERO
			sprite.play("idle")
	if event.is_action_released("stop"):
		is_stopped = false
		if has_stored_position:
			target_position = stored_target_position
			target_position_changed.emit(target_position)
			is_moving = true
			has_stored_position = false
			sprite.play("walk")
		
	if event.is_action_pressed("space"):
		drain_stamina()
	if event.is_action_released("space"):
		is_boosted = false
		
	if event.is_action_pressed("right-click"):
		var mouse_pos = get_global_mouse_position()
		var local_pos = walkable_tiles.to_local(mouse_pos)
		if is_valid_move_target(local_pos):
			target_position = mouse_pos
			target_position_changed.emit(target_position)
			
			if is_stopped:
				stored_target_position = target_position
				has_stored_position = true
			else:
				is_moving = true
				sprite.play("walk")

func _physics_process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var local_pos = walkable_tiles.to_local(mouse_pos)
	if is_valid_move_target(local_pos):
		CursorManager.set_cursor_with_priority("walk", self)
	else:
		CursorManager.set_cursor_with_priority("disabled", self)
		
	if !is_boosted and !is_refreshing:
		replenish_stamina()
	
	if is_stopped:
		return
	
	if current_target:
		basic_attack()
	
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
			if is_boosted:
				velocity = direction * speed * 2
			else:
				velocity = direction * speed
			
			if has_node("AnimatedSprite2D"):
				if direction.x < 0:
					sprite.flip_h = true
				elif direction.x > 0:
					sprite.flip_h = false
	
	move_and_slide()

func take_damage(damage_taken: int) -> void:
	sprite.play("hurt")
	current_health -= damage_taken
	health_changed.emit(current_health)
	
	spawn_damage_popup(damage_taken, "normal")
	
	if current_health <= 0:
		kill_player()

func heal_damage(heal_amount: int) -> void:
	var heal_fx = HEALING_EFFECT.instantiate()
	get_tree().get_first_node_in_group("effects").add_child(heal_fx)
	heal_fx.global_position = get_sprite_content_center()
	var duration := 6.0  # Duration in seconds
	var ticks := 60  # Number of healing ticks
	var heal_per_tick := float(heal_amount) / ticks
	var heal_interval := duration / ticks
	
	var popup = HEALING_POPUP.instantiate()
	add_child(popup)
	popup.setup(heal_amount)
	
	for i in ticks:
		await get_tree().create_timer(heal_interval).timeout
		var current_tick_heal = heal_per_tick
		
		if current_health + current_tick_heal > health:
			current_tick_heal = health - current_health
			
		if current_tick_heal <= 0:
			break
			
		current_health += current_tick_heal
		health_changed.emit(current_health)
		
		if i % 5 == 0:
			var tick_popup = HEALING_POPUP.instantiate()
			add_child(tick_popup)
			tick_popup.setup(round(current_tick_heal))


func kill_player() -> void:
	sprite.play("death")
	died.emit()
	process_mode = PROCESS_MODE_DISABLED

func drain_stamina() -> void:
	is_boosted = true
	while current_stamina > 0 and is_boosted:
		await get_tree().create_timer(0.02).timeout
		current_stamina -= 1
		stamina_changed.emit(current_stamina)
	
	if current_stamina == 0:
		is_boosted = false

func replenish_stamina() -> void:
	if current_stamina >= stamina:
		return
		
	is_refreshing = true
		
	if current_stamina < stamina and !is_boosted:
		get_tree().get_frame()
		current_stamina += 1
		stamina_changed.emit(current_stamina)
	
	stamina_regen.start()

func _on_stamina_regen_timeout() -> void:
	is_refreshing = false

func target_enemy(enemy: Enemy) -> void:
	if enemy.is_dead:
		return
	
	if current_target and current_target != enemy:
		current_target.set_is_targeted(false)
	
	current_target = enemy
	
	if not enemy.tree_exiting.is_connected(_on_target_died):
		enemy.tree_exiting.connect(_on_target_died.bind(enemy))

func _on_target_died(enemy: Enemy) -> void:
	if current_target == enemy:
		current_target = null

func clear_current_target() -> void:
	if current_target:
		current_target.set_is_targeted(false)
		current_target = null

func basic_attack() -> void:
	if !current_target or !basic_attack_timer.is_stopped():
		return
		
	if !is_instance_valid(current_target) or current_target.is_dead:
		clear_current_target()
		return
	
	sprite.play("shoot")
	
	var magic_missile = MAGIC_MISSILE.instantiate()
	magic_missile.set_damage(basic_damage)
	get_tree().get_first_node_in_group("projectiles").add_child(magic_missile)
	magic_missile.global_position = global_position
	magic_missile.launch(current_target.get_sprite_content_center())
	
	basic_attack_timer.start()

func is_valid_move_target(pos: Vector2) -> bool:
	var tile_pos = walkable_tiles.local_to_map(pos)
	var tile_id = walkable_tiles.get_cell_source_id(tile_pos)
	if tile_id == -1:
		return false
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = walkable_tiles.to_global(pos)
	query.collision_mask = collision_mask
	var result = space_state.intersect_point(query)
	
	return result.is_empty()

func _exit_tree() -> void:
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
	# Add to a designated effects layer or canvas layer for consistent rendering
	add_child(popup)
	popup.setup(damage, type, is_crit)

func get_missing_health() -> int:
	return health - current_health

func collect_room_pickups() -> void:
	PickupManager.get_instance().collect_all_pickups(self)

func gain_experience(amount: int) -> void:
	current_experience += amount
	experience_gained.emit(amount)
