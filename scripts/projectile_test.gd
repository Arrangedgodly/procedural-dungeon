extends Node2D

const FIREBALL = preload("res://scenes/projectiles/fireball.tscn")	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		var fireball_scene = FIREBALL.instantiate()
		add_child(fireball_scene)
		fireball_scene.position += Vector2(600, 400)
		var random_pos = Vector2(randi_range(0, 1200), randi_range(0, 800))
		print(random_pos)
		fireball_scene.launch(random_pos)
