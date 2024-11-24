extends TextureProgressBar

@export var background_color: Color
@export var under_color: Color
@export var progress_color: Color
@onready var progress: TextureProgressBar = $Progress

func _ready() -> void:
	if background_color or under_color or progress_color:
		set_colors()
	
	progress.value_changed.connect(_on_progress_value_changed)

func init(maximum_value: int) -> void:
	progress.max_value = maximum_value
	progress.value = maximum_value
	self.max_value = maximum_value
	self.value = maximum_value

func set_progress_value(new_value: float) -> void:
	progress.value = new_value
	
func get_progress() -> float:
	return progress.value

func _on_progress_value_changed(new_value: float) -> void:
	var target_value = new_value
	var current_value = self.value
	
	if current_value <= target_value:
		self.value = target_value
	elif current_value > target_value:
		var tween = create_tween()
		tween.tween_property(self, "value", target_value, 2)
		await tween.finished

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
