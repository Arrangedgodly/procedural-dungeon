extends Node

var mimics: Array = []

func _ready() -> void:
	load_items()

func load_items():
	var dir = DirAccess.open("res://scenes/items/mimics")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Only process .tscn files
			if file_name.ends_with(".tscn"):
				var mimic_scene = load("res://scenes/items/mimics/" + file_name)
				if mimic_scene:
					mimics.append(mimic_scene)
			file_name = dir.get_next()
			
		dir.list_dir_end()
	else:
		print("Error: Unable to access items directory")

func get_mimic_by_index(index: int):
	if index >= 0 and index < mimics.size():
		return mimics[index]
	return null

func instantiate_mimic(index: int) -> Node:
	var mimic = get_mimic_by_index(index)
	if mimic:
		return mimic.instantiate()
	return null

func instantiate_random_mimic() -> Node:
	var random_num = randi_range(0, mimics.size() - 1)
	return instantiate_mimic(random_num)
