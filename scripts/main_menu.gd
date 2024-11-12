extends Control

func _on_dungeon_generator_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/basic_dungeon.tscn")

func _on_enemy_selector_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/enemy_selector.tscn")

func _on_credits_pressed() -> void:
	pass # Replace with function body.
