extends Camera2D

var is_zooming: bool = false
var zoom_in: bool = false
var target_position: Vector2 = Vector2.ZERO

const MAX_ZOOM: float = 4.0
const MIN_ZOOM: float = 0.5
const SMOOTHING_SPEED: float = 1.75

func _process(delta: float) -> void:
	target_position = get_local_mouse_position()
	position = position.lerp(target_position, delta * SMOOTHING_SPEED)
	
	if is_zooming:
		is_zooming = false
		if zoom_in:
			if self.zoom.x < MAX_ZOOM:
				self.zoom.x += .2
				self.zoom.y += .2
		else:
			if self.zoom.x > MIN_ZOOM:
				self.zoom.x -= .2
				self.zoom.y -= .2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll-up"):
		is_zooming = true
		zoom_in = true
	if event.is_action_pressed("scroll-down"):
		is_zooming = true
		zoom_in = false
