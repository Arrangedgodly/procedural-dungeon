extends TextureProgressBar

@export var background_color: Color
@export var under_color: Color
@export var progress_color: Color
@onready var progress: TextureProgressBar = $Progress

func _ready() -> void:
	if background_color or under_color or progress_color:
		set_colors()

func init(max: int) -> void:
	print("Progress Bar initialized")
	progress.max_value = max
	progress.value = max
	self.max_value = max
	self.value = max

func set_progress_value(new_value: float) -> void:
	progress.value = new_value
	
func get_progress() -> float:
	return progress.value

func _on_progress_value_changed(new_value: float) -> void:
	print(self.name + " max value is " + str(self.max_value))
	var target_value = new_value
	print(self.name + " target value is " + str(target_value))
	var current_value = self.value
	print(self.name + " current Value is " + str(current_value))
	
	if current_value <= target_value:
		current_value = target_value
	elif current_value > target_value:
		var tween = create_tween()
		tween.tween_property(self, "value", target_value, 1)

func set_colors() -> void:
	self.tint_progress = background_color
	self.tint_under = under_color
	progress.tint_progress = progress_color

func set_background_color(new_color: Color) -> void:
	background_color = new_color

func set_under_color(new_color: Color) -> void:
	under_color = new_color

func set_progress_color(new_color: Color) -> void:
	progress_color = new_color
