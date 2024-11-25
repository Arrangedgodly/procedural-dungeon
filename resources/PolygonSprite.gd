@icon("res://assets/icons/icon_hitbox.png")
extends AnimatedSprite2D
class_name PolygonSprite

var _previous_flip_h := flip_h
var _previous_flip_v := flip_v
@export var collision_scale := Vector2(1, 1)
var detection_area: Area2D
var detection_shape: CollisionShape2D
var is_processing_polygons := false

func _ready() -> void:
	setup_detection_area()
	self.frame_changed.connect(_on_frame_changed)
	
func setup_detection_area() -> void:
	detection_area = Area2D.new()
	detection_shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	
	var texture_size = sprite_frames.get_frame_texture(animation, 0).get_size()
	var radius = max(texture_size.x, texture_size.y)
	circle.radius = radius
	
	detection_shape.shape = circle
	detection_area.add_child(detection_shape)
	add_child(detection_area)
	
	detection_area.body_entered.connect(_on_object_entered)
	detection_area.body_exited.connect(_on_object_exited)
	detection_area.area_entered.connect(_on_object_entered)
	detection_area.area_exited.connect(_on_object_exited)

func _on_object_entered(_object: Node2D) -> void:
	if not is_processing_polygons:
		is_processing_polygons = true
		create_polygons(animation, frame)
		set_process(true)

func _on_object_exited(_object: Node2D) -> void:
	if detection_area.get_overlapping_bodies().size() == 0 and detection_area.get_overlapping_areas().size() == 0:
		is_processing_polygons = false
		clear_polygons()
		set_process(false)

func create_polygons(anim: String, idx: int) -> void:
	if not is_processing_polygons:
		return
		
	var frame_texture = sprite_frames.get_frame_texture(anim, idx)
	var image = frame_texture.get_image()
	var texture_size = frame_texture.get_size()
	
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)
	var polys = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, texture_size), 1)
	
	for poly in polys:
		var collision_polygon = CollisionPolygon2D.new()
		var centered_poly = PackedVector2Array()
		for point in poly:
			var centered_point = point - texture_size/2
			centered_point *= collision_scale
			centered_poly.append(centered_point)
		
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
	if is_processing_polygons:
		clear_polygons()
		create_polygons(animation, frame)

func _process(_delta: float) -> void:
	if is_processing_polygons and (_previous_flip_h != flip_h or _previous_flip_v != flip_v):
		_on_flip_changed()
		_previous_flip_h = flip_h
		_previous_flip_v = flip_v

func _on_flip_changed() -> void:
	if is_processing_polygons:
		clear_polygons()
		create_polygons(animation, frame)
