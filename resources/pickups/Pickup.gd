extends Area2D
class_name Pickup

signal collected(pickup: Pickup)

@export var base_speed: float = 400.0
@export var max_speed: float = 1200.0
@export var acceleration: float = 1000.0
@export var collect_sound: AudioStream

var velocity: Vector2 = Vector2.ZERO
var current_speed: float = 0.0
var is_being_collected: bool = false
var target: Node2D

func _ready() -> void:
	add_to_group("pickup")
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	if is_being_collected and is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)
		velocity = direction * current_speed
		
		position += velocity * delta
		
		var distance = global_position.distance_to(target.global_position)
		if distance < 10:
			complete_collection()

func start_collection(new_target: Node2D) -> void:
	if not is_being_collected:
		is_being_collected = true
		target = new_target
		current_speed = base_speed

func complete_collection() -> void:
	if target and target is Player:
		if collect(target):
			collected.emit(self)
			queue_free()

func collect(player: Player) -> bool:
	return false

func can_be_collected(player: Player) -> bool:
	return false

func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		var player = area.get_parent()
		if can_be_collected(player):
			start_collection(player)

func play_sfx(player: Player) -> void:
	SoundManager.play_sfx(collect_sound, "Player", player.global_position)
