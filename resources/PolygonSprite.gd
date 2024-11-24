@icon("res://assets/icons/icon_hitbox.png")
extends AnimatedSprite2D
class_name PolygonSprite

var _previous_flip_h := flip_h
var _previous_flip_v := flip_v
@export var collision_scale := Vector2(1, 1)

func create_polygons(anim: String, idx: int) -> void:
	var frame_texture = sprite_frames.get_frame_texture(anim, idx)
	var image = frame_texture.get_image()
	var texture_size = frame_texture.get_size()
	
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	var polys = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, texture_size), 1)
	
	for poly in polys:
		var collision_polygon = CollisionPolygon2D.new()
		
		# Center the polygon based on texture size
		var centered_poly = PackedVector2Array()
		for point in poly:
			var centered_point = point - texture_size/2
			centered_point *= collision_scale
			centered_poly.append(centered_point)
		
		# Apply sprite flipping to the polygon
		if flip_h:
			for i in range(centered_poly.size()):
				centered_poly[i].x = -centered_poly[i].x
		if flip_v:
			for i in range(centered_poly.size()):
				centered_poly[i].y = -centered_poly[i].y
				
		collision_polygon.polygon = centered_poly
		
		get_parent().call_deferred("add_child", collision_polygon)

func clear_polygons() -> void:
	for child in get_parent().get_children():
		if child is CollisionPolygon2D:
			child.queue_free()

func _on_frame_changed() -> void:
	clear_polygons()
	create_polygons(animation, frame)

func _on_flip_changed() -> void:
	clear_polygons()
	create_polygons(animation, frame)

func _ready() -> void:
	self.frame_changed.connect(_on_frame_changed)
	create_polygons(animation, frame)

func _process(_delta: float) -> void:
	# Check if flip state has changed
	if _previous_flip_h != flip_h or _previous_flip_v != flip_v:
		_on_flip_changed()
		_previous_flip_h = flip_h
		_previous_flip_v = flip_v
