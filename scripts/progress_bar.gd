extends TextureProgressBar

@export var background_color: Color
@export var under_color: Color
@export var progress_color: Color
@onready var progress: TextureProgressBar = $Progress

func _ready() -> void:
	self.tint_progress = background_color
	self.tint_under = under_color
	progress.tint_progress = progress_color

func init(max: int) -> void:
	progress.max_value = max
	progress.value = max
	self.max_value = max
	self.value = max

func set_progress_value(new_value: float) -> void:
	progress.value = new_value
	
func get_progress() -> float:
	return progress.value

func _on_progress_value_changed(new_value: float) -> void:
	var target_value = new_value
	var current_value = self.value
	
	if current_value < target_value:
		current_value = target_value
	elif current_value > target_value:
		while current_value > target_value:
			self.value = current_value
			await get_tree().create_timer(.025).timeout
			current_value -= 1
		
	if current_value == target_value:
		self.value = current_value
