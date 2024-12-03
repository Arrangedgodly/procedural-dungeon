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

func instantiate_enemy_by_index(index: int) -> Node:
	var enemy = get_enemy_by_index(index)
	if enemy:
		return enemy.instantiate()
	return null

func instantiate_random_enemy() -> Node:
	var random_num = randi_range(0, enemies.size() - 1)
	return instantiate_enemy_by_index(random_num)

func get_enemy_index_by_path(path: String) -> int:
	path = path.replace("res://", "")
	
	for i in range(enemies.size()):
		if enemies[i].resource_path.ends_with(path):
			return i
	
	return -1  # Return -1 if not found

func instantiate_enemy_by_path(path: String) -> Node:
	if not path.begins_with("res://scenes/enemies/"):
		path = "res://scenes/enemies/" + path
	
	if not path.ends_with(".tscn"):
		path = path + ".tscn"
	
	# Try to load the scene
	var enemy_scene = load(path)
	if enemy_scene:
		return enemy_scene.instantiate()
	
	print("Error: Could not load enemy scene at path: ", path)
	return null
