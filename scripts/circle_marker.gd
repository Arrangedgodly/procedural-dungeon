extends Node2D
@onready var arrow: Sprite2D = $Arrow

func _on_red_player_target_position_changed(pos: Vector2) -> void:
	position = pos
	show()

func _ready() -> void:
	animate_arrow()
	hide()

func _on_red_player_target_position_reached() -> void:
	hide()
	
func animate_arrow() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(arrow, "position:y", -16, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(arrow, "position:y", -8, 0.5).set_trans(Tween.TRANS_SINE)
