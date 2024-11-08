extends Node

var common: Array = []
var uncommon: Array = []
var rare: Array = []
var legendary: Array = []

func _ready():
	load_items("common", common)
	load_items("uncommon", uncommon)
	load_items("rare", rare)
	load_items("legendary", legendary)

func load_items(directory: String, item_array: Array):
	var dir = DirAccess.open("res://scenes/items/" + directory)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			# Only process .tscn files
			if file_name.ends_with(".tscn"):
				var item_scene = load("res://scenes/items/" + directory + "/" + file_name)
				if item_scene:
					item_array.append(item_scene)
			file_name = dir.get_next()
			
		dir.list_dir_end()
	else:
		print("Error: Unable to access items directory")
		
func get_item_by_index(index: int, item_array: Array):
	if index >= 0 and index < item_array.size():
		return item_array[index]
	return null

func instantiate_item(index: int, item_array: Array) -> Node:
	var item = get_item_by_index(index, item_array)
	if item:
		return item.instantiate()
	return null

func instantiate_random_item() -> Node:
	var random_num = randf()
	var item_array: Array
	
	if random_num <= 0.4:
		item_array = common
	elif random_num <= .65 and random_num > 0.4:
		item_array = uncommon
	elif random_num <= .85 and random_num > 0.65:
		item_array = rare
	elif random_num <= 1.0 and random_num > 0.85:
		item_array = legendary
	
	var random_index = randi_range(0, item_array.size() - 1)
	return instantiate_item(random_index, item_array)
