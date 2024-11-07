extends Node2D
class_name RoomGenerator
signal texture_generated
signal map_generation_started
signal map_generation_finished

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
var is_generating: bool = false
var has_texture: bool = false
var active_chunks = {}
var target_zoom := Vector2.ONE
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
const CHUNK_SIZE = 64
const ZOOM_DURATION := 0.5
const MIN_ZOOM := 0.01
const MAX_ZOOM := .5
const OVERVIEW_ZOOM_MULTIPLIER := 1.0
const FOLLOW_MOUSE_ZOOM_MULTIPLIER := 5.0
const FOCUSED_ROOM_ZOOM_MULTIPLIER := 3.0

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
	map_generation_finished.emit()

func make_map():
	walk.clear()
	background.clear()
	walls.clear()
	active_chunks.clear()
	
	# First pass: Calculate total bounds and identify active chunks
	var full_rect = Rect2()
	for room in rooms.get_children():
		var rect = Rect2(room.position - room.size, room.get_node("CollisionShape2D").shape.extents * 2)
		full_rect = full_rect.merge(rect)
		
		# Mark chunks containing this room as active
		var top_left = walk.local_to_map(rect.position)
		var bottom_right = walk.local_to_map(rect.end)
		for x in range(get_chunk_coord(top_left).x, get_chunk_coord(bottom_right).x + 1):
			for y in range(get_chunk_coord(top_left).y, get_chunk_coord(bottom_right).y + 1):
				active_chunks[Vector2i(x, y)] = true
	
	# Process chunks in batches
	var processed = 0
	var total_chunks = active_chunks.size()
	
	for chunk_coord in active_chunks:
		var chunk_bounds = get_chunk_bounds(chunk_coord)
		generate_chunk(chunk_bounds)
		
		processed += 1
		if processed % 10 == 0:  # Process in batches of 10 chunks
			await get_tree().process_frame  # Yield to prevent freezing

	# Generate corridors in batches
	var corridors = []
	var rooms_processed = 0
	
	for room in rooms.get_children():
		generate_room_and_corridors(room, corridors)
		
		rooms_processed += 1
		if rooms_processed % 5 == 0:  # Process in batches of 5 rooms
			await get_tree().process_frame

func generate_chunk(bounds: Rect2i) -> void:
	# Generate background tiles for chunk
	for x in range(bounds.position.x, bounds.position.x + bounds.size.x):
		for y in range(bounds.position.y, bounds.position.y + bounds.size.y):
			set_background_cell(Vector2i(x, y))

func generate_room_and_corridors(room: Node, corridors: Array) -> void:
	var size = (room.size / tile_size).floor()
	var pos = walk.local_to_map(room.position)
	var upper_left = (room.position / tile_size).floor() - size
	
	# Set room interior cells
	for x in range(2, size.x * 2 - 1):
		for y in range(2, size.y * 2 - 1):
			set_walkable_cell(Vector2i(upper_left.x + x, upper_left.y + y))
	
	# Draw room outline
	draw_room_outline(upper_left, size)
	
	# Generate corridors
	var point = path.get_closest_point(Vector2(room.position.x, room.position.y))
	for connection in path.get_point_connections(point):
		if connection not in corridors:
			var start = walk.local_to_map(Vector2(path.get_point_position(point).x, path.get_point_position(point).y))
			var end = walk.local_to_map(Vector2(path.get_point_position(connection).x, path.get_point_position(connection).y))
			carve_path(start, end)
	corridors.append(point)

# Modified carve_path to be more efficient
func carve_path(pos1: Vector2i, pos2: Vector2i) -> void:
	var x_diff = sign(pos2.x - pos1.x)
	var y_diff = sign(pos2.y - pos1.y)
	if x_diff == 0: x_diff = 1
	if y_diff == 0: y_diff = 1
	
	var corridor_cells = []
	var current = pos1
	var batch_size = 5  # Process corridors in smaller batches
	var cells_in_batch = []
	
	# Generate corridor cells in batches
	while current.x != pos2.x:
		cells_in_batch.append_array(get_corridor_segment_cells(current, Vector2i(1, 0)))
		current.x += x_diff
		
		if cells_in_batch.size() >= batch_size:
			process_corridor_batch(cells_in_batch)
			cells_in_batch.clear()
	
	while current.y != pos2.y:
		cells_in_batch.append_array(get_corridor_segment_cells(current, Vector2i(0, 1)))
		current.y += y_diff
		
		if cells_in_batch.size() >= batch_size:
			process_corridor_batch(cells_in_batch)
			cells_in_batch.clear()
	
	# Process any remaining cells
	if cells_in_batch.size() > 0:
		process_corridor_batch(cells_in_batch)

func get_corridor_segment_cells(center: Vector2i, direction: Vector2i) -> Array:
	var cells = []
	var half_width = dungeon_size.corridor_width / 2
	var perpendicular = Vector2i(-direction.y, direction.x)
	var start_pos = center - (perpendicular * int(half_width))
	
	for i in range(dungeon_size.corridor_width):
		cells.append(start_pos + (perpendicular * i))
	
	return cells

func process_corridor_batch(cells: Array) -> void:
	for cell in cells:
		set_walkable_cell(cell)
		
		# Add walls around corridor cells
		for dir in DIRECTIONS:
			var check_pos = cell + dir
			if not is_walkable_tile(check_pos):
				set_wall_cell(check_pos)

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
	
	var room_size = max(room.size.x, room.size.y)
	var viewport_size = get_viewport_rect().size
	var zoom_level = viewport_size.x / (room_size * 4)  # 4 is a factor to ensure room fits
	var new_zoom = Vector2.ONE * zoom_level * FOCUSED_ROOM_ZOOM_MULTIPLIER
	
	var tween = create_tween()
	tween.set_parallel(true)  # Allow position and zoom to animate simultaneously
	tween.tween_property(camera, "position", room.position, ZOOM_DURATION)
	set_camera_zoom(new_zoom)

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
		var current_zoom = camera.zoom.x
		var new_zoom = Vector2.ONE * (current_zoom * FOLLOW_MOUSE_ZOOM_MULTIPLIER)
		set_camera_zoom(new_zoom)

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
		
	# Calculate bounds of all rooms
	var bounds = Rect2()
	var first_room = true
	
	for room in rooms.get_children():
		var room_rect = Rect2(room.position - room.size, room.size * 2)
		
		if first_room:
			bounds = room_rect
			first_room = false
		else:
			bounds = bounds.merge(room_rect)
	
	# Add padding to the bounds (10% on each side)
	var padding = bounds.size * 0.1
	bounds = bounds.grow(padding.x)
	
	# Get the viewport size
	var viewport_size = get_viewport_rect().size
	
	# Calculate the zoom level needed to fit the entire dungeon
	var zoom_x = viewport_size.x / bounds.size.x
	var zoom_y = viewport_size.y / bounds.size.y
	
	# Use the smaller zoom value to ensure everything fits
	var zoom_level = min(zoom_x, zoom_y)
	zoom_level *= 0.9
	
	var new_zoom = Vector2.ONE
	match camera_state:
		CameraState.OVERVIEW:
			new_zoom = Vector2(zoom_level, zoom_level) * OVERVIEW_ZOOM_MULTIPLIER
		CameraState.FOLLOWING_MOUSE:
			new_zoom = Vector2(zoom_level, zoom_level) * FOLLOW_MOUSE_ZOOM_MULTIPLIER
		CameraState.FOCUSED_ON_ROOM:
			new_zoom = Vector2(zoom_level, zoom_level) * FOCUSED_ROOM_ZOOM_MULTIPLIER
	
	# Update camera position and zoom
	camera_init_pos = bounds.get_center()
	camera.position = camera_init_pos
	set_camera_zoom(new_zoom)
	
	match camera_state:
		CameraState.OVERVIEW:
			camera.zoom = Vector2(zoom_level, zoom_level)
		CameraState.FOLLOWING_MOUSE:
			camera.zoom = Vector2(0.25, 0.25)
		CameraState.FOCUSED_ON_ROOM:
			camera.zoom = Vector2(0.5, 0.5)

func set_camera_zoom(new_zoom: Vector2, duration: float = ZOOM_DURATION) -> void:
	# Clamp the zoom values
	new_zoom.x = clamp(new_zoom.x, MIN_ZOOM, MAX_ZOOM)
	new_zoom.y = clamp(new_zoom.y, MIN_ZOOM, MAX_ZOOM)
	
	target_zoom = new_zoom
	
	# Create and configure the tween
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "zoom", new_zoom, duration)

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
		CameraState.FOCUSED_ON_ROOM:
			if current_focused_room:
				camera.position = current_focused_room.position
		CameraState.OVERVIEW:
			camera.position = camera_init_pos

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
	texture_generated.emit()

func _on_ui_trigger_generate_map() -> void:
	map_generation_started.emit()
	apply_settings()

func get_chunk_coord(tile_pos: Vector2i) -> Vector2i:
	return Vector2i(
		floor(float(tile_pos.x) / CHUNK_SIZE),
		floor(float(tile_pos.y) / CHUNK_SIZE)
	)

func get_chunk_bounds(chunk_coord: Vector2i) -> Rect2i:
	var start = chunk_coord * CHUNK_SIZE
	return Rect2i(start, Vector2i(CHUNK_SIZE, CHUNK_SIZE))
