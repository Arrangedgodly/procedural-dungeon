extends Node

var custom_cursors: Dictionary = {}

func _ready() -> void:
	add_cursor("click", preload("res://assets/cursors/click.png"))
	add_cursor("crosshair", preload("res://assets/cursors/crosshair.png"))
	add_cursor("dialog", preload("res://assets/cursors/dialog.png"))
	add_cursor("disabled", preload("res://assets/cursors/disabled.png"))
	add_cursor("locked", preload("res://assets/cursors/locked.png"))
	add_cursor("unlock", preload("res://assets/cursors/unlock.png"))
	add_cursor("walk", preload("res://assets/cursors/walk.png"))
	
	set_cursor("click")

func add_cursor(name: String, image: Resource) -> void:
	custom_cursors[name] = {
		"image": image,
		"hotspot": Vector2(16, 16)
	}

func set_cursor(cursor_name: String) -> void:
	if custom_cursors.has(cursor_name):
		var cursor_data = custom_cursors[cursor_name]
		Input.set_custom_mouse_cursor(
			cursor_data["image"],
			Input.CURSOR_ARROW,
			cursor_data["hotspot"]
		)

func reset_cursor() -> void:
	set_cursor("click")
