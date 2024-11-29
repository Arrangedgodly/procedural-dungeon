extends Node

var custom_cursors: Dictionary = {}
var current_cursors: Dictionary = {}
const CURSOR_SCALE := 2.0

const PRIORITY_MAP = {
	"disabled": 0,
	"walk": 1,
	"crosshair": 2,
	"dialog": 3,
	"unlock": 3,
	"locked": 3,
	"click": 0
}

const HOTSPOT_OFFSETS = {
	"click": Vector2(0, 0),  # Point at top-left corner of the arrow
	"crosshair": Vector2(16, 16),  # Center of the crosshair
	"dialog": Vector2(0, 0),
	"disabled": Vector2(0, 0),
	"locked": Vector2(16, 16),  # Center
	"unlock": Vector2(16, 16),  # Center
	"walk": Vector2(16, 16)     # Center
}

func _ready() -> void:
	add_cursor("click", scale_cursor_texture(preload("res://assets/cursors/click.png")))
	add_cursor("crosshair", scale_cursor_texture(preload("res://assets/cursors/crosshair.png")))
	add_cursor("dialog", scale_cursor_texture(preload("res://assets/cursors/dialog.png")))
	add_cursor("disabled", scale_cursor_texture(preload("res://assets/cursors/disabled.png")))
	add_cursor("locked", scale_cursor_texture(preload("res://assets/cursors/locked.png")))
	add_cursor("unlock", scale_cursor_texture(preload("res://assets/cursors/unlock.png")))
	add_cursor("walk", scale_cursor_texture(preload("res://assets/cursors/walk.png")))
	
	set_cursor("click")

func add_cursor(name: String, image: Resource) -> void:
	var base_hotspot = HOTSPOT_OFFSETS[name]
	
	custom_cursors[name] = {
		"image": image,
		"hotspot": base_hotspot * CURSOR_SCALE
	}

func scale_cursor_texture(texture: Texture2D) -> Texture2D:
	var image = texture.get_image()
	var original_size = Vector2i(image.get_width(), image.get_height())
	var new_size = Vector2i(original_size.x * CURSOR_SCALE, original_size.y * CURSOR_SCALE)
	image.resize(new_size.x, new_size.y, Image.INTERPOLATE_NEAREST)
	return ImageTexture.create_from_image(image)

func set_cursor_with_priority(cursor_name: String, source: Object) -> void:
	current_cursors[source] = cursor_name
	update_cursor()

func remove_cursor_source(source: Object) -> void:
	if current_cursors.has(source):
		current_cursors.erase(source)
		update_cursor()

func update_cursor() -> void:
	var highest_priority_cursor = "click"
	var highest_priority = -1
	
	for cursor in current_cursors.values():
		var priority = PRIORITY_MAP.get(cursor, 0)
		if priority > highest_priority:
			highest_priority = priority
			highest_priority_cursor = cursor
	
	set_cursor(highest_priority_cursor)

func set_cursor(cursor_name: String) -> void:
	if custom_cursors.has(cursor_name):
		var cursor_data = custom_cursors[cursor_name]
		Input.set_custom_mouse_cursor(
			cursor_data["image"],
			Input.CURSOR_ARROW,
			cursor_data["hotspot"]
		)

func reset_cursor() -> void:
	current_cursors.clear()
	set_cursor("click")
