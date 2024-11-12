extends Node2D

func instantiate_enemy(enemy_path: String):
	var enemy_instance = EnemyManager.instantiate_enemy_by_path(enemy_path)
	add_child(enemy_instance)
