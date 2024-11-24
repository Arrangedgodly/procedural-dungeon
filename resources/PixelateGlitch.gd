extends Node
class_name PixelateGlitch

const pixelate_shader = preload("res://shaders/pixelate.gdshader")
signal pixelate_up_done
signal pixelate_down_done

func _ready() -> void:
	var shader_material = ShaderMaterial.new()
	shader_material.shader = pixelate_shader
	self.material = shader_material
	
	pixelate_up_done.connect(pixelate_down)
	pixelate_down_done.connect(pixelate_up)
	pixelate_up()
	
func pixelate_loop(up: bool) -> void:
	var max = 512
	var min = 256
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
