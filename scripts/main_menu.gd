extends Control

@export var menu_music: AudioStream

func _ready() -> void:
	SoundManager.play_music(menu_music)

func _on_dungeon_generator_pressed() -> void:
	SoundManager.stop(menu_music)
	get_tree().change_scene_to_file("res://scenes/basic_dungeon.tscn")

func _on_enemy_selector_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/enemy_selector.tscn")

func _on_credits_pressed() -> void:
	pass # Replace with function body.
