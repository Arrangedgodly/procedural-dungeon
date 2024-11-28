@icon("res://assets/icons/icon_particle.png")
extends AnimatedSprite2D
class_name Effect

@export var modification_color: Color
@export var z_level: int = 5

func _ready() -> void:
	self.z_index = z_level
	
	self.animation_finished.connect(queue_free)
	
	if modification_color:
		self.modulate = modification_color

func set_modification_color(new_color: Color) -> void:
	modification_color = new_color
	self.modulate = modification_color
