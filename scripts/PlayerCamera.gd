extends Camera2D

var is_zooming: bool = false
var zoom_in: bool = false

const MAX_ZOOM: float = 4.0
const MIN_ZOOM: float = 0.5

func _process(delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	position = mouse_pos
	
	if is_zooming:
		is_zooming = false
		if zoom_in:
			if self.zoom.x < MAX_ZOOM:
				self.zoom.x += .1
				self.zoom.y += .1
		else:
			if self.zoom.x > MIN_ZOOM:
				self.zoom.x -= .1
				self.zoom.y -= .1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll-up"):
		is_zooming = true
		zoom_in = true
	if event.is_action_pressed("scroll-down"):
		is_zooming = true
		zoom_in = false
