extends Area2D
class_name PickupZone

signal zone_size_changed(new_radius: float)

@export var initial_radius: float = 50.0
@export var zone_shape: CollisionShape2D

var current_radius: float = 0.0

func _ready() -> void:
	setup_zone()

func setup_zone() -> void:
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = initial_radius
	zone_shape.shape = circle_shape
	current_radius = initial_radius
	
func set_zone_radius(new_radius: float) -> void:
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = new_radius
	zone_shape.shape = circle_shape
	current_radius = new_radius
	zone_size_changed.emit(new_radius)
