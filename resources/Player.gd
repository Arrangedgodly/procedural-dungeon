extends CharacterBody2D
class_name Player
signal target_position_changed(pos: Vector2)
signal target_position_reached
signal health_changed(new_health: int)
signal mana_changed(new_mana: int)
signal stamina_changed(new_stamina: int)
signal died

@export var sprite: AnimatedSprite2D
@export var collision_shape: CollisionShape2D
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

const MAGIC_MISSILE = preload("res://scenes/projectiles/magic_missile.tscn")

func _ready() -> void:
	current_health = health
	current_stamina = stamina
	current_mana = mana
	stamina_regen.timeout.connect(_on_stamina_regen_timeout)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("space"):
		drain_stamina()
	if event.is_action_released("space"):
		is_boosted = false

func _physics_process(_delta: float) -> void:
	if !is_boosted and !is_refreshing:
		replenish_stamina()
	
	if current_target:
		basic_attack()
		
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
	
	if current_health <= 0:
		kill_player()

func heal_damage(heal_amount: int) -> void:
	current_health += heal_amount
	health_changed.emit(current_health)

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
	magic_missile.launch(current_target.global_position)
	
	basic_attack_timer.start()
