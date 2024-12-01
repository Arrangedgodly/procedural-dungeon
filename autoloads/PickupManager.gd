extends Node

var increase_experience_count: bool = false
var experience_to_spawn: int = 0
var spawning_experience: bool = false

func instantiate_pickup_by_path(path: String) -> Node:
	if not path.begins_with("res://scenes/items/pickups/"):
		path = "res://scenes/items/pickups/" + path
	if not path.ends_with(".tscn"):
		path = path + ".tscn"
	
	# Try to load the scene
	var pickup_scene = load(path)
	if pickup_scene:
		return pickup_scene.instantiate()
	
	print("Error: Could not load pickup scene at path: ", path)
	return null

func create_pickup(path: String, pos: Vector2) -> void:
	var pickup = instantiate_pickup_by_path(path)
	get_tree().get_first_node_in_group("pickups").add_child(pickup)
	pickup.global_position = pos

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("health"):
		if OS.is_debug_build():
			var player = get_tree().get_first_node_in_group("player")
			var random_pos = player.global_position + Vector2(randi_range(-50, 50), randi_range(-50, 50))
			create_pickup("health_pack", random_pos)
	if event.is_action_pressed("experience"):
		if OS.is_debug_build():
			increase_experience_count = true
	if event.is_action_released("experience"):
		if OS.is_debug_build():
			increase_experience_count = false

func _process(delta: float) -> void:
	if increase_experience_count:
		experience_to_spawn += 1
		await get_tree().process_frame
	else:
		if experience_to_spawn > 0 and !spawning_experience:
			spawning_experience = true
			spawn_experience()

func spawn_experience() -> void:
	while experience_to_spawn > 0:
		var player = get_tree().get_first_node_in_group("player")
		var random_pos = player.global_position + Vector2(randi_range(-500, 500), randi_range(-500, 500))
		create_pickup("experience_gem", random_pos)
		experience_to_spawn -= 1
	
	spawning_experience = false
