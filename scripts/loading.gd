extends Control

@onready var resource: Label = $Resource
@onready var loading: Label = $Loading
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

func _ready() -> void:
	self.hide()

func _on_basic_dungeon_generation_phase_changed(phase: String) -> void:
	self.show()
	resource.text = phase
	resource.position.x = -(resource.size.x / 2)
	texture_progress_bar.value = 0

func _on_basic_dungeon_generation_progress_updated(phase: String, progress: float) -> void:
	texture_progress_bar.value = progress
	loading.text = str(round(progress)) + "%"
	loading.position.x = -(loading.size.x / 2)
	if progress == 100:
		self.hide()
