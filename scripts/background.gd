extends PixelateGlitch

var background_paths: Array[String] = []

func _ready() -> void:
	get_background_paths()
	set_random_background()
	super._ready()

func get_background_paths() -> void:
	var dir = DirAccess.open("res://assets/backgrounds")
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".webp"):
				background_paths.append(file_name)
			file_name = dir.get_next()
			
		dir.list_dir_end()

func set_random_background() -> void:
	if background_paths.size() > 0:
		var random_file = background_paths[randi() % background_paths.size()]
		var background = load("res://assets/backgrounds/" + random_file)
		if background:
			self.texture = background
		else:
			push_error("Failed to load background: " + random_file)
	else:
		push_error("Error: No backgrounds found in directory")

func _on_swap_pages_pressed() -> void:
	set_random_background()
