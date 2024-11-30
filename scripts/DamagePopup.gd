extends Control
class_name DamagePopup

const CRIT_SCALE = 1.5
const ARC_HEIGHT = 50.0  # Maximum height of the arc
const HORIZONTAL_SPREAD = 30.0  # Maximum horizontal spread
const ANIMATION_DURATION = 1.0
const FADE_DELAY = 0.3  # When to start fading during animation

@onready var label = $Label
@onready var shadow_label = $ShadowLabel

# Arc motion control points
var current_time: float = 0.0
var arc_control_points: Array[Vector2]

func _ready() -> void:
	self.z_index = 50
	modulate = Color(1, 1, 1, 1)
	setup_arc_motion()
	animate()
	process_mode = PROCESS_MODE_ALWAYS

func setup(value: int, type: String = "normal", critical: bool = false) -> void:
	# Set text value
	label.text = str(value)
	shadow_label.text = str(value)
	
	# Apply color based on damage type
	match type:
		"normal":
			label.add_theme_color_override("font_color", Color(1, 1, 1))
		"fire":
			label.add_theme_color_override("font_color", Color(1, 0.5, 0))
		"ice":
			label.add_theme_color_override("font_color", Color(0.5, 0.8, 1))
		"poison":
			label.add_theme_color_override("font_color", Color(0, 1, 0.5))
		"heal":
			label.add_theme_color_override("font_color", Color(0, 1, 0))
	
	# Apply critical hit scaling and effects
	if critical:
		scale = Vector2.ONE * CRIT_SCALE
		label.add_theme_color_override("font_outline_color", Color(1, 0.5, 0))

func setup_arc_motion() -> void:
	# Calculate random direction for the arc
	var angle = randf_range(-PI/4, PI/4)  # -45 to 45 degrees
	var direction = Vector2(cos(angle), sin(angle))
	
	# Start from current global position
	var start = global_position
	var end = start + direction * HORIZONTAL_SPREAD
	
	# Calculate the peak point of the arc
	var mid = (start + end) / 2
	mid.y -= ARC_HEIGHT  # Peak of the arc
	
	# Store control points for the quadratic Bézier curve
	arc_control_points = [
		start,
		mid,
		end
	]
	
	# Set initial position to start point
	global_position = start

func quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	return q0.lerp(q1, t)

func animate() -> void:
	# Initial pop animation
	var pop_tween = create_tween()
	pop_tween.tween_property(self, "scale", Vector2.ONE, 0.1)\
		.from(Vector2.ZERO)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_ELASTIC)
	
	# Start the fade out after a delay
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, ANIMATION_DURATION - FADE_DELAY)\
		.set_delay(FADE_DELAY)\
		.set_ease(Tween.EASE_IN)
	
	# Enable processing for arc motion
	set_process(true)

func _process(delta: float) -> void:
	current_time += delta / ANIMATION_DURATION
	
	if current_time >= 1.0:
		queue_free()
		return
	
	# Update position along the arc using global coordinates
	global_position = quadratic_bezier(
		arc_control_points[0],
		arc_control_points[1],
		arc_control_points[2],
		current_time
	)
