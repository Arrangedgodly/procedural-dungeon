extends RigidBody2D

signal room_clicked(room: Node)

var size
var pos
var is_highlighted: bool = false
var is_focused: bool = false
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func make_room(_pos, _size):
	pos = _pos
	size = _size
	position = pos
	var shape = RectangleShape2D.new()
	shape.extents = size
	collision_shape.shape = shape
	
	input_pickable = true
	
	queue_redraw()
	
func _draw() -> void:
	# Draw room outline
	if $CollisionShape2D.shape:
		var collision_rect = Rect2(-$CollisionShape2D.shape.size/2, $CollisionShape2D.shape.size)
		var color = Color.GREEN if is_highlighted else Color.TRANSPARENT
		if color == Color.GREEN:
			color.a = .2
		draw_rect(collision_rect, color, true, -1.0, false)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		if not is_focused:
			room_clicked.emit(self)

func _on_mouse_entered() -> void:
	if not is_focused:
		is_highlighted = true
		queue_redraw()

func _on_mouse_exited() -> void:
	if not is_focused:
		is_highlighted = false
		queue_redraw()

func set_focused(focused: bool) -> void:
	is_focused = focused
	is_highlighted = focused
	input_pickable = !focused
	queue_redraw()
