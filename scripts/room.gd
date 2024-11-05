extends RigidBody2D

var size
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func make_room(_pos, _size):
	position = _pos
	size = _size
	var shape = RectangleShape2D.new()
	shape.extents = size
	collision_shape.shape = shape
