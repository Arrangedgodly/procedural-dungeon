extends Node2D
@onready var player = load("res://scenes/characters/red_player.tscn")

func instantiate_enemy(enemy_path: String):
	var enemy_instance = EnemyManager.instantiate_enemy_by_path(enemy_path)
	add_child(enemy_instance)

func instantiate_player():
	var player_instance = player.instantiate()
	add_child(player_instance)
	player_instance.position.y += 126
