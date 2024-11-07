extends Node

var items: Array = []

func _ready():
	load_items()

func load_items():
	var dir = DirAccess.open("res://scenes/items")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Only process .tscn files
			if file_name.ends_with(".tscn"):
				var item_scene = load("res://scenes/items/" + file_name)
				if item_scene:
					items.append(item_scene)
			file_name = dir.get_next()
			
		dir.list_dir_end()
	else:
		print("Error: Unable to access items directory")

func get_items() -> Array:
	return items

func get_item_by_index(index: int):
	if index >= 0 and index < items.size():
		return items[index]
	return null

func instantiate_item(index: int) -> Node:
	var item = get_item_by_index(index)
	if item:
		return item.instantiate()
	return null

func instantiate_random_item() -> Node:
	var random_num = randi_range(0, items.size() - 1)
	return instantiate_item(random_num)
