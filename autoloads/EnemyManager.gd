extends Node

var enemies = []

func _ready() -> void:
	load_enemies()

func load_enemies():
	var dir = DirAccess.open("res://scenes/enemies")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Only process .tscn files
			if file_name.ends_with(".tscn"):
				var enemy_scene = load("res://scenes/enemies/" + file_name)
				if enemy_scene:
					enemies.append(enemy_scene)
			file_name = dir.get_next()
			
		dir.list_dir_end()
	else:
		print("Error: Unable to access items directory")

func get_enemy_by_index(index: int):
	if index >= 0 and index < enemies.size():
		return enemies[index]
	return null

func instantiate_enemy(index: int) -> Node:
	var enemy = get_enemy_by_index(index)
	if enemy:
		return enemy.instantiate()
	return null

func instantiate_random_enemy() -> Node:
	var random_num = randi_range(0, enemies.size() - 1)
	return instantiate_enemy(random_num)
