extends AnimatedSprite2D
class_name PolygonSprite

func create_polygons(anim: String, idx: int) -> void:
	var bitmap = BitMap.new()
	var frame_texture = self.sprite_frames.get_frame_texture(anim, idx)
	bitmap.create_from_image_alpha(frame_texture.get_image())
	var polys = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, frame_texture.get_size()), 0.75)
	for poly in polys:
		var collision_polygon = CollisionPolygon2D.new()
		collision_polygon.polygon = poly
		collision_polygon.position.x -= 16
		collision_polygon.position.y -= 16
		get_parent().add_child(collision_polygon)

func clear_polygons() -> void:
	for child in get_parent().get_children():
		if child is CollisionPolygon2D:
			child.queue_free()

func _on_frame_changed() -> void:
	clear_polygons()
	create_polygons(animation, frame)

func _ready() -> void:
	self.frame_changed.connect(_on_frame_changed)
