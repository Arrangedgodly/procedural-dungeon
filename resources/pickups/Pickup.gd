# res://resources/pickups/Pickup.gd
extends Area2D
class_name Pickup

signal collected(by: Node2D)

@export var sprite: Sprite2D
@export var collect_sound: AudioStream
@export var collision: CollisionShape2D

var is_being_collected: bool = false
var collection_speed: float = 400.0
var target: Node2D

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)
	add_to_group("pickups")

func _physics_process(delta: float) -> void:
	if is_being_collected and is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		position += direction * collection_speed * delta
		
		if global_position.distance_to(target.global_position) < 10:
			collect()

func start_collection(collector: Node2D) -> void:
	is_being_collected = true
	target = collector

func collect() -> void:
	if collect_sound:
		SoundManager.play_sfx(collect_sound, "Pickups", global_position)
	collected.emit(target)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and !is_being_collected:
		collect()

func should_auto_collect(player: Node2D) -> bool:
	return true
