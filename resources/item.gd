extends StaticBody2D
class_name Item

@export var sprite_texture: Texture2D

func _ready() -> void:
	var sprite_2d = Sprite2D.new()
	sprite_2d.texture = sprite_texture
	add_child(sprite_2d)
	var collision_shape_2d = CollisionShape2D.new()
	var collision_shape = RectangleShape2D.new()
	collision_shape.size = Vector2(32, 32)
	collision_shape_2d.shape = collision_shape
	add_child(collision_shape_2d)
