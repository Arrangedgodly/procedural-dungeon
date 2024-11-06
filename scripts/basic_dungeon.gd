extends Node2D
class_name RoomGenerator

var Room = preload("res://scenes/room.tscn")

var dungeon_size: DungeonSize
@export var rooms: Node
@export var tiles: Node2D
@export var walk: TileMapLayer
@export var background: TileMapLayer
@export var walls: TileMapLayer
@export var camera: Camera2D
@export var ui: Control

var camera_init_pos: Vector2
var tile_size = 32
var path: AStar2D
var current_focused_room: Node = null
var camera_state = CameraState.OVERVIEW

enum CameraState {
	OVERVIEW,
	FOLLOWING_MOUSE,
	FOCUSED_ON_ROOM
}

const DIRECTIONS = [
	Vector2i(0, -1), #North
	Vector2i(1, -1), #Northeast
	Vector2i(1, 0), #East
	Vector2i(1, 1), #Southeast
	Vector2i(0, 1), #South
	Vector2i(-1, 1), #Southwest
	Vector2i(-1, 0), #West
	Vector2i(-1, -1) #Northwest
]

func _ready() -> void:
	randomize()
	await ensure_dungeon_size()
	ui.set_dungeon_size(dungeon_size)
	create_layout()
	setup_camera()

func setup_camera() -> void:
	camera_init_pos = camera.position
	camera.zoom = Vector2(0.075, 0.075)  # Default overview zoom
	fit_camera_to_rooms()
	
func make_rooms() -> void:
	for i in range(dungeon_size.rooms_generated):
		var width = dungeon_size.min_size + randi() % (dungeon_size.max_size - dungeon_size.min_size)
		var height = dungeon_size.min_size + randi() % (dungeon_size.max_size - dungeon_size.min_size)
		var pos = Vector2(randi_range(-dungeon_size.horizontal_spread, dungeon_size.horizontal_spread), 0)
		
		var room_instance = Room.instantiate()
		rooms.add_child(room_instance)
		room_instance.make_room(pos, Vector2(width, height) * tile_size)
		
		# Make room clickable
		room_instance.room_clicked.connect(_on_room_clicked)

func cull_rooms():
	var room_positions = []
	for room in rooms.get_children():
		if randf() < dungeon_size.cull_amount:
			room.queue_free()
		else:
			room.freeze = true
			room_positions.append(Vector2(room.position.x, room.position.y))
			
	await get_tree().create_timer(.1).timeout
	path = find_mst(room_positions)

func find_mst(nodes):
	path = AStar2D.new()
	var first_point = path.get_available_point_id()
	path.add_point(first_point, nodes.pop_front())
	
	while nodes:
		var min_dist = INF
		var min_pos = null
		var current_pos = null
		var current_id = -1
		
		# Check distances from each point in the path
		for point_id in path.get_point_ids():
			var point_pos = path.get_point_position(point_id)
			
			# Compare with each remaining node
			for next_pos in nodes:
				var dist = point_pos.distance_to(next_pos)
				if dist < min_dist:
					min_dist = dist
					min_pos = next_pos
					current_pos = point_pos
					current_id = point_id
		
		# Add the closest point to the path
		var next_id = path.get_available_point_id()
		path.add_point(next_id, min_pos)
		path.connect_points(current_id, next_id)
		nodes.erase(min_pos)
	
	return path

func create_layout():
	make_rooms()
	await get_tree().create_timer(1.0).timeout
	cull_rooms()
	fit_camera_to_rooms()

func make_map():
	walk.clear()
	background.clear()
	walls.clear()
	# First pass: Set Background Cells
	var full_rect = Rect2()
	for room in rooms.get_children():
		var rect = Rect2(room.position - room.size, room.get_node("CollisionShape2D").shape.extents * 2)
		full_rect = full_rect.merge(rect)
	var top_left = walk.local_to_map(full_rect.position)
	var bottom_right = walk.local_to_map(full_rect.end)
	for x in range(top_left.x, bottom_right.x):
		for y in range(top_left.y, bottom_right.y):
			set_background_cell(Vector2i(x, y))
	
	#Second pass: Set Room Cells
	var corridors = []
	for room in rooms.get_children():
		var size = (room.size / tile_size).floor()
		var pos = walk.local_to_map(room.position)
		var upper_left = (room.position / tile_size).floor() - size
		
		#Set Room Interior Cells
		for x in range(2, size.x * 2 - 1):
			for y in range(2, size.y * 2 - 1):
				set_walkable_cell(Vector2i(upper_left.x + x, upper_left.y + y))
		
		#Draw Room Outlines
		draw_room_outline(upper_left, size)
		
		#Connect Rooms with Corridors
		var point = path.get_closest_point(Vector2(room.position.x, room.position.y))
		for connection in path.get_point_connections(point):
			if connection not in corridors:
				var start = walk.local_to_map(Vector2(path.get_point_position(point).x, path.get_point_position(point).y))
				var end = walk.local_to_map(Vector2(path.get_point_position(connection).x, path.get_point_position(connection).y))
				carve_path(start, end)
		corridors.append(point)

func carve_path(pos1, pos2):
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0: x_diff = 1
	if y_diff == 0: y_diff = 1
	
	var corridor_cells = []
	var current = pos1
	
	while current.x != pos2.x:
		carve_wide_corridor_segment(current, Vector2i(1, 0), corridor_cells)
		current.x += x_diff
	while current.y != pos2.y:
		carve_wide_corridor_segment(current, Vector2i(0, 1), corridor_cells)
		current.y += y_diff
	carve_wide_corridor_segment(pos2, Vector2i(0, 1), corridor_cells)
	
	add_corridor_walls(corridor_cells)

func carve_wide_corridor_segment(center: Vector2i, direction: Vector2i, corridor_cells: Array):
	var half_width = dungeon_size.corridor_width / 2
	var perpendicular = Vector2i(-direction.y, direction.x)
	var start_pos = center - (perpendicular * int(half_width))
	
	for i in range(dungeon_size.corridor_width):
		var pos = start_pos + (perpendicular * i)
		set_walkable_cell(pos)
		corridor_cells.append(pos)

func add_corridor_walls(corridor_cells: Array):
	var wall_positions = {}
	
	#Check all adjacent tiles for each corridor cell
	for cell in corridor_cells:
		for dir in DIRECTIONS:
			var check_pos = cell + dir
			
			#Only add wall if the position is not a walkable tile
			if not is_walkable_tile(check_pos) and not wall_positions.has(check_pos):
				wall_positions[check_pos] = true
				set_wall_cell(check_pos)

func is_walkable_tile(pos: Vector2i):
	return walk.get_cell_source_id(pos) != -1
	
func set_walkable_cell(pos: Vector2i):
	walk.tile_map_data
	walk.set_cell(pos, randi_range(0, 7), Vector2(0, 0), 0)

func set_background_cell(pos: Vector2i):
	background.set_cell(pos, 0, Vector2(0, 0), 0)
	
func set_wall_cell(pos: Vector2i):
	walls.set_cell(pos, randi_range(0, 4), Vector2(0, 0), 0)

func draw_room_outline(upper_left: Vector2, size: Vector2):
	for x in range(1, size.x * 2):
		set_wall_cell(Vector2i(upper_left.x + x, upper_left.y + 1)) #Top Wall
		set_wall_cell(Vector2i(upper_left.x + x, upper_left.y + size.y * 2 - 1)) #Bottom Wall
		
	for y in range(1, size.y * 2):
		set_wall_cell(Vector2i(upper_left.x + 1, upper_left.y + y)) #Left Wall
		set_wall_cell(Vector2i(upper_left.x + size.x * 2 - 1, upper_left.y + y)) #Right Wall
	
	#Draw Corners
	set_wall_cell(Vector2i(upper_left.x + 1, upper_left.y + 1)) #Top Left
	set_wall_cell(Vector2i(upper_left.x + size.x * 2 - 1, upper_left.y + 1)) #Top Right
	set_wall_cell(Vector2i(upper_left.x + 1, upper_left.y + size.y * 2 - 1)) #Bottom Left
	set_wall_cell(Vector2i(upper_left.x + size.x * 2 - 1, upper_left.y + size.y * 2 - 1)) #Bottom Right

func _on_room_clicked(room: Node) -> void:
	focus_on_room(room)

func focus_on_room(room: Node) -> void:
	if current_focused_room:
		current_focused_room.set_focused(false)
	
	current_focused_room = room
	current_focused_room.set_focused(true)
	camera_state = CameraState.FOCUSED_ON_ROOM

func focus_next_room() -> void:
	if not current_focused_room or rooms.get_child_count() == 0:
		return
		
	var current_index = current_focused_room.get_index()
	var next_index = (current_index + 1) % rooms.get_child_count()
	
	current_focused_room.set_focused(false)
	
	current_focused_room = rooms.get_child(next_index)
	current_focused_room.set_focused(true)

func set_all_rooms_interactive(interactive: bool) -> void:
	for room in rooms.get_children():
		if room != current_focused_room:
			room.input_pickable = interactive

func toggle_mouse_follow() -> void:
	if camera_state == CameraState.FOLLOWING_MOUSE:
		reset_camera_to_overview()
	else:
		camera_state = CameraState.FOLLOWING_MOUSE

func reset_camera_to_overview() -> void:
	camera_state = CameraState.OVERVIEW
	
	# Unfocus current room if any
	if current_focused_room:
		current_focused_room.set_focused(false)
		current_focused_room = null
	
	fit_camera_to_rooms()

func fit_camera_to_rooms() -> void:
	if rooms.get_child_count() == 0:
		return
		
	var bounds = Rect2()
	var first_room = true
	
	for room in rooms.get_children():
		var room_rect = Rect2(
			room.position - room.size,
			room.size * 2
		)
		
		if first_room:
			bounds = room_rect
			first_room = false
		else:
			bounds = bounds.merge(room_rect)
	
	# Add padding to the bounds (10% on each side)
	var padding = bounds.size * 0.1
	bounds = bounds.grow(padding.x)
	
	# Update camera initial position and bounds
	camera_init_pos = bounds.get_center()
	camera.position = camera_init_pos

func apply_settings() -> void:
	if not dungeon_size:
		return
	
	# Clear existing rooms and regenerate
	for room in rooms.get_children():
		room.queue_free()
	path = null
	walk.clear()
	background.clear()
	walls.clear()
	
	# Reset camera
	reset_camera_to_overview()
	
	create_layout()

func ensure_dungeon_size() -> void:
	if not dungeon_size:
		dungeon_size = DungeonSize.new()

func _draw():
	for room in rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2), Color(32, 228, 0), false, 32)
	if path:
		for point in path.get_point_ids():
			for connection in path.get_point_connections(point):
				var point_pos = path.get_point_position(point)
				var connection_pos = path.get_point_position(connection)
				draw_line(point_pos, connection_pos, Color(0, 255, 0), 32, true)

func _process(_delta: float) -> void:
	queue_redraw()
	match camera_state:
		CameraState.FOLLOWING_MOUSE:
			camera.position = get_global_mouse_position()
			camera.zoom = Vector2(0.25, 0.25)
		CameraState.FOCUSED_ON_ROOM:
			if current_focused_room:
				camera.position = current_focused_room.position
				camera.zoom = Vector2(0.5, 0.5)
		CameraState.OVERVIEW:
			camera.position = camera_init_pos
			camera.zoom = Vector2(0.05, 0.05)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):  # Escape key
		reset_camera_to_overview()
	elif event.is_action_pressed("ui_focus_next"):  # Tab key
		if camera_state == CameraState.FOCUSED_ON_ROOM:
			focus_next_room()
	elif event.is_action_pressed("ui_select"):  # Space key
		toggle_mouse_follow()
	elif event.is_action_pressed("right-click"):
		tiles.visible = false
	elif event.is_action_released("right-click"):
		tiles.visible = true


func _on_ui_trigger_generate_layers() -> void:
	make_map()


func _on_ui_trigger_generate_map() -> void:
	apply_settings()
