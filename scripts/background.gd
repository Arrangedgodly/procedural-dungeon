extends TextureRect

var backgrounds: Array[Texture2D] = []
const pixelate_shader = preload("res://shaders/pixelate.gdshader")
signal pixelate_up_done
signal pixelate_down_done

func _ready() -> void:
	preload_backgrounds()
	set_random_background()
	
	var shader_material = ShaderMaterial.new()
	shader_material.shader = pixelate_shader
	self.material = shader_material
	
	pixelate_up_done.connect(pixelate_down)
	pixelate_down_done.connect(pixelate_up)
	pixelate_up()

func preload_backgrounds() -> void:
	var dir = DirAccess.open("res://assets/backgrounds")
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".webp"):
				var text = load("res://assets/backgrounds/" + file_name)
				if text:
					backgrounds.append(text)
			file_name = dir.get_next()
			
		dir.list_dir_end()

func set_random_background() -> void:
	if backgrounds.size() > 0:
		self.texture = backgrounds[randi() % backgrounds.size()]
	else:
		print("Error: No backgrounds loaded")

func _on_swap_pages_pressed() -> void:
	set_random_background()

func pixelate_loop(up: bool) -> void:
	var max = 256
	var min = 128
	var i: int
	if up:
		i = min
		while i < max:
			self.material.set_shader_parameter("amount", i)
			await get_tree().create_timer(.1).timeout
			i += 1
		
		if i == max:
			pixelate_up_done.emit()
	else:
		i = max
		while i > min:
			self.material.set_shader_parameter("amount", i)
			await get_tree().create_timer(.1).timeout
			i -= 1
		
		if i == min:
			pixelate_down_done.emit()

func pixelate_up() -> void:
	pixelate_loop(true)

func pixelate_down() -> void:
	pixelate_loop(false)
