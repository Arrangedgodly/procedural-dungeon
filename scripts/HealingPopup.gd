extends DamagePopup
class_name HealingPopup

func _ready() -> void:
	var style = StyleBoxFlat.new()
	style.shadow_color = Color(0, 1, 0, 0.35)
	style.shadow_size = 4
	label.add_theme_stylebox_override("normal", style)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 40, 2.0).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 2.0).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)

func setup(amount: int, type: String = "heal", is_crit: bool = false) -> void:
	label.text = "+" + str(amount)
	label.add_theme_color_override("font_color", Color(0.2, 1, 0.2))
	
	position.x += randf_range(-10, 10)
	position.y += randf_range(-5, 5)
