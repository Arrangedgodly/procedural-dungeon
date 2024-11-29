extends Node2D

const FIREBALL = preload("res://scenes/projectiles/fireball.tscn")
const DAMAGE_POPUP = preload("res://scenes/damage_popup.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		var fireball_scene = FIREBALL.instantiate()
		add_child(fireball_scene)
		fireball_scene.position = Vector2(600, 400)
		var random_pos = Vector2(randi_range(0, 1200), randi_range(0, 800))
		fireball_scene.launch(random_pos)
	if event.is_action_pressed("right-click"):
		var popup_scene = DAMAGE_POPUP.instantiate()
		add_child(popup_scene)
		popup_scene.set_starting_position(Vector2(600, 400))
		var is_crit = randf() <= 0.2
		popup_scene.setup(randi_range(5, 50), "normal", is_crit)
