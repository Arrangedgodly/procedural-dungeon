extends Control
class_name HealingPopup

# Animation constants
const FLOAT_DURATION = 1.5
const FLOAT_DISTANCE = 40.0
const PULSE_SCALE = 1.2
const PULSE_DURATION = 0.4

@onready var label = $Label
@onready var shadow_label = $ShadowLabel

var initial_position: Vector2
var current_time: float = 0.0

func _ready() -> void:
	self.z_index = 50
	modulate = Color(1, 1, 1, 1)
	initial_position = position
	animate()
	process_mode = PROCESS_MODE_ALWAYS

func setup(value: int) -> void:
	# Set text value
	label.text = str(value)
	shadow_label.text = str(value)
	
	# Set healing color theme (bright green)
	label.add_theme_color_override("font_color", Color(0.2, 1, 0.2))
	
	# Add a slight glow effect
	label.add_theme_color_override("font_outline_color", Color(0.4, 1, 0.4, 0.5))
	label.add_theme_constant_override("outline_size", 2)

func animate() -> void:
	# Initial pop and pulse animation
	var pop_tween = create_tween()
	pop_tween.set_parallel(true)
	
	# Initial scale from zero
	pop_tween.tween_property(self, "scale", Vector2.ONE, 0.2)\
		.from(Vector2.ZERO)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)
	
	# Pulse sequence
	var pulse_tween = create_tween()
	pulse_tween.set_loops(2)  # Pulse twice
	
	# Scale up
	pulse_tween.tween_property(self, "scale", Vector2.ONE * PULSE_SCALE, PULSE_DURATION * 0.5)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_SINE)
	
	# Scale back down
	pulse_tween.tween_property(self, "scale", Vector2.ONE, PULSE_DURATION * 0.5)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_SINE)
	
	# Start the float and fade animation
	var float_tween = create_tween()
	float_tween.set_parallel(true)
	
	# Floating upward motion
	float_tween.tween_property(self, "position:y", 
		initial_position.y - FLOAT_DISTANCE, 
		FLOAT_DURATION)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_SINE)
	
	# Fade out near the end of the float
	float_tween.tween_property(self, "modulate:a", 
		0.0, 
		FLOAT_DURATION * 0.3)\
		.set_delay(FLOAT_DURATION * 0.7)\
		.set_ease(Tween.EASE_IN)
	
	# Queue for deletion after animation
	await float_tween.finished
	queue_free()

func _process(_delta: float) -> void:
	# Add a subtle sideways hover motion
	var hover_offset = sin(current_time * 5) * 2
	position.x = initial_position.x + hover_offset
	current_time += _delta
