extends Area2D
class_name Pickup

signal collected(pickup)

@export var sprite: AnimatedSprite2D
@export var collect_sound: AudioStream
var is_being_collected: bool = false
var collection_speed: float = 400.0
var target: Node2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	if is_being_collected and target:
		var direction = (target.global_position - global_position).normalized()
		position += direction * collection_speed * delta
		
		# Check if we've reached the target
		if global_position.distance_to(target.global_position) < 10:
			collect()

func start_collection(collector: Node2D) -> void:
	is_being_collected = true
	target = collector

func collect() -> void:
	if collect_sound:
		SoundManager.play_sfx(collect_sound, "Pickups", global_position)
	collected.emit(self)
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area is PickupZone and !is_being_collected:
		start_collection(area.get_parent())
