extends TextureRect

var backgrounds: Array[Texture2D] = []

func _ready() -> void:
	preload_backgrounds()
	set_random_background()

func preload_backgrounds() -> void:
	var dir = DirAccess.open("res://assets/backgrounds")
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".webp"):
				var texture = load("res://assets/backgrounds/" + file_name)
				if texture:
					backgrounds.append(texture)
			file_name = dir.get_next()
			
		dir.list_dir_end()

func set_random_background() -> void:
	if backgrounds.size() > 0:
		self.texture = backgrounds[randi() % backgrounds.size()]
	else:
		print("Error: No backgrounds loaded")

func _on_swap_pages_pressed() -> void:
	set_random_background()
