extends Control

@onready var resource: Label = $Resource
@onready var loading: Label = $Loading
@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar
@onready var spin_wheel: AnimatedSprite2D = $AnimatedSprite2D

var spin_wheel_height

func _ready() -> void:
	self.hide()
	spin_wheel_height = spin_wheel.sprite_frames.get_frame_texture("default", 0).get_height() * 5 #Using 5x multiplier to account for the sprite scaling up
	print("Spin Wheel Height:" + str(spin_wheel_height))

func _on_basic_dungeon_generation_phase_changed(phase: String) -> void:
	self.show()
	resource.text = phase
	resource.position.x = -(resource.size.x / 2)
	resource.position.y = -(resource.size.y - 25) - (spin_wheel_height / 2)
	loading.position.x = -(loading.size.x / 2)
	loading.position.y = -(loading.size.y / 2)
	texture_progress_bar.value = 0

func _on_basic_dungeon_generation_progress_updated(phase: String, progress: float) -> void:
	texture_progress_bar.value = progress
	loading.text = str(round(progress)) + "%"
	if progress == 100:
		self.hide()

func _on_basic_dungeon_generation_phase_color(new_color: Color) -> void:
	loading.set("theme_override_colors/font_shadow_color", new_color)
	resource.set("theme_override_colors/font_shadow_color", new_color)
	spin_wheel.modulate = new_color
	texture_progress_bar.tint_progress = new_color
