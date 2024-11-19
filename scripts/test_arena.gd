extends Node2D

func _ready() -> void:
	var enemy_path = get_tree().get_root().get_meta("selected_enemy_path")
	if enemy_path:
		instantiate_enemy(enemy_path)
		get_tree().get_root().remove_meta("selected_enemy_path")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/enemy_selector.tscn")
		
func instantiate_enemy(enemy_path: String):
	var enemy_instance = EnemyManager.instantiate_enemy_by_path(enemy_path)
	add_child(enemy_instance)
