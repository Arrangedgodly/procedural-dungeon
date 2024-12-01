extends Area2D
class_name PlayerPickupZone

@export var base_radius: float = 30.0
var current_radius_multiplier: float = 1.0
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	setup_collection_zone()

func setup_collection_zone() -> void:
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = base_radius
	collision_shape.shape = circle_shape
	update_radius()

func set_radius_multiplier(multiplier: float) -> void:
	current_radius_multiplier = multiplier
	update_radius()

func update_radius() -> void:
	var circle_shape = collision_shape.shape as CircleShape2D
	circle_shape.radius = base_radius * current_radius_multiplier
