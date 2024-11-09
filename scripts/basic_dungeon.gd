extends Node2D
class_name RoomGenerator
signal texture_generated
signal map_generation_started
signal map_generation_finished
signal generation_phase_color(new_color: Color)
signal generation_progress_updated(phase: String, progress: float)
signal generation_phase_changed(phase: String)

var Room = preload("res://scenes/room.tscn")

var dungeon_size: DungeonSize
@export var rooms: Node
@export var tiles: Node2D
@export var walk: TileMapLayer
@export var background: TileMapLayer
@export var walls: TileMapLayer
@export var camera: Camera2D
@export var ui: Control
@export var items: Node2D

var camera_init_pos: Vector2
var tile_size = 32
var path: AStar2D
var current_focused_room: Node = null
var is_generating: bool = false
var has_texture: bool = false
var active_chunks = {}
var target_zoom := Vector2.ONE
var camera_state = CameraState.OVERVIEW
var current_phase: String = ""
var items_to_process: int = 0
var items_processed: int = 0
var room_previous_positions = {}

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
const PHASES = {
	"ROOMS": "Generating Rooms",
	"SETTLING": "Settling Room Positions",
	"CHUNKS": "Generating Map Chunks",
	"TEXTURES": "Placing Tile Textures",
	"ITEMS": "Spawning Items"
}
const PHASE_COLORS = {
	"ROOMS": Color.RED,
	"SETTLING": Color.ORANGE,
	"CHUNKS": Color.YELLOW,
	"TEXTURES": Color.GREEN,
	"ITEMS": Color.BLUE
}
const ROOM_BATCH_SIZE = 20
const CHUNK_SIZE = 64
const ZOOM_DURATION := 0.8
const MIN_ZOOM := 0.01
const MAX_ZOOM := .75
const OVERVIEW_ZOOM_MULTIPLIER := 1.0
const FOLLOW_MOUSE_ZOOM_MULTIPLIER := 5.0
const FOCUSED_ROOM_ZOOM_MULTIPLIER := 1.25
const MIN_ITEMS_PER_ROOM := 0
const MAX_ITEMS_PER_ROOM := 2
const ITEMS_BATCH_SIZE := 5
const MIN_EDGE_PADDING := 512.0

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
	set_phase("ROOMS")
	items_to_process = dungeon_size.rooms_generated
	items_processed = 0
	
	var rooms_remaining = dungeon_size.rooms_generated
	var current_batch = []
	
	for room in rooms.get_children():
		room.freeze = true
	
	while rooms_remaining > 0:
		var batch_size = mini(ROOM_BATCH_SIZE, rooms_remaining)
		current_batch.clear()
		
		# Prepare batch of room data
		for i in range(batch_size):
			var width = dungeon_size.min_size + randi() % (dungeon_size.max_size - dungeon_size.min_size)
			var height = dungeon_size.min_size + randi() % (dungeon_size.max_size - dungeon_size.min_size)
			var pos = Vector2(randi_range(-dungeon_size.horizontal_spread, dungeon_size.horizontal_spread), 0)
			
			current_batch.append({
				"width": width,
				"height": height,
				"position": pos
			})
		
		# Process the batch
		await process_room_batch(current_batch)
		rooms_remaining -= batch_size
		await get_tree().process_frame

func process_room_batch(batch: Array) -> void:
	for room_data in batch:
		var room_instance = Room.instantiate()
		rooms.add_child(room_instance)
		room_instance.freeze = true
		room_instance.make_room(
			room_data.position, 
			Vector2(room_data.width, room_data.height) * tile_size
		)
		room_instance.room_clicked.connect(_on_room_clicked)
		
		items_processed += 1
		update_progress()

func start_room_settling() -> void:
	set_phase("SETTLING")
	items_processed = 0
	update_progress()
	
	# Store initial positions before unfreezing
	room_previous_positions.clear()
	for room in rooms.get_children():
		room_previous_positions[room] = room.position
	
	# Unfreeze in batches
	var rooms_per_batch = 20
	var room_children = rooms.get_children()
	
	for i in range(0, room_children.size(), rooms_per_batch):
		var batch_end = mini(i + rooms_per_batch, room_children.size())
		for j in range(i, batch_end):
			room_children[j].sleeping = false
			room_children[j].freeze = false
		await get_tree().physics_frame
	
	await wait_for_rooms_to_settle()

func wait_for_rooms_to_settle() -> void:
	var stable_frames := 0
	const REQUIRED_STABLE_FRAMES := 30
	const MAX_SETTLING_TIME := 15.0
	var settling_timer := 0.0
	
	while stable_frames < REQUIRED_STABLE_FRAMES and settling_timer < MAX_SETTLING_TIME:
		var moving_rooms := count_moving_rooms()
		var total_rooms := rooms.get_child_count()
		
		if total_rooms > 0:
			items_processed = int(((total_rooms - moving_rooms) / float(total_rooms)) * 100)
			update_progress()
		
		if moving_rooms == 0:
			stable_frames += 1
		else:
			stable_frames = 0
		
		settling_timer += get_physics_process_delta_time()
		await get_tree().physics_frame
		
		# Update previous positions for next check
		for room in rooms.get_children():
			room_previous_positions[room] = room.position
	
	for room in rooms.get_children():
		room.freeze = true
	
	items_processed = 100
	update_progress()
	room_previous_positions.clear()

func count_moving_rooms() -> int:
	var moving := 0
	var movement_threshold = 0.1  # Adjust if needed
	
	for room in rooms.get_children():
		if not room.freeze:
			var prev_pos = room_previous_positions.get(room, room.position)
			var movement = room.position.distance_to(prev_pos)
			if movement > movement_threshold:
				moving += 1
	return moving

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
	if is_generating:
		return
		
	is_generating = true
	
	await make_rooms()
	await start_room_settling()
	await cull_rooms()
	fit_camera_to_rooms()
	map_generation_finished.emit()
	
	is_generating = false

# Optional: Add a function to cancel generation if needed
func cancel_generation() -> void:
	if is_generating:
		# Force freeze all rooms
		for room in rooms.get_children():
			room.freeze = true
		is_generating = false

func make_map() -> void:
	clear_map_state()
	process_map_bounds()
	await process_chunks()
	await process_room_corridors()
	await distribute_items()

func clear_map_state() -> void:
	walk.clear()
	background.clear()
	walls.clear()
	active_chunks.clear()

func process_map_bounds() -> void:
	var full_rect := Rect2()
	for room in rooms.get_children():
		var rect := get_room_bounds(room)
		full_rect = full_rect.merge(rect)
		mark_active_chunks(rect)

func process_chunks() -> void:
	set_phase("CHUNKS")
	items_processed = 0
	items_to_process = active_chunks.size()
	
	for chunk_coord in active_chunks:
		var chunk_bounds = get_chunk_bounds(chunk_coord)
		generate_chunk(chunk_bounds)
		
		items_processed += 1
		update_progress()
		if items_processed % 10 == 0:  # Process in batches of 10 chunks
			await get_tree().process_frame

func process_room_corridors() -> void:
	set_phase("TEXTURES")
	var corridors = []
	items_to_process = rooms.get_child_count()
	items_processed = 0
	
	for room in rooms.get_children():
		generate_room_and_corridors(room, corridors)
		
		items_processed += 1
		update_progress()
		
		if items_processed % 5 == 0:
			await get_tree().process_frame

func get_room_bounds(room: Node) -> Rect2:
	return Rect2(
		room.position - room.size,
		room.get_node("CollisionShape2D").shape.extents * 2
	)

func mark_active_chunks(rect: Rect2) -> void:
	var top_left := walk.local_to_map(rect.position)
	var bottom_right := walk.local_to_map(rect.end)
	for x in range(get_chunk_coord(top_left).x, get_chunk_coord(bottom_right).x + 1):
		for y in range(get_chunk_coord(top_left).y, get_chunk_coord(bottom_right).y + 1):
			active_chunks[Vector2i(x, y)] = true

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

func carve_path(pos1: Vector2i, pos2: Vector2i) -> void:
	var direction := Vector2i(sign(pos2.x - pos1.x), sign(pos2.y - pos1.y))
	direction = Vector2i(1 if direction.x == 0 else direction.x, 1 if direction.y == 0 else direction.y)
	
	var current := pos1
	var cells := []
	
	while current.x != pos2.x:
		cells.append_array(get_corridor_segment_cells(current, Vector2i(1, 0)))
		current.x += direction.x
		process_cells_batch(cells)
	
	while current.y != pos2.y:
		cells.append_array(get_corridor_segment_cells(current, Vector2i(0, 1)))
		current.y += direction.y
		process_cells_batch(cells)

func process_cells_batch(cells: Array) -> void:
	const BATCH_SIZE := 5
	if cells.size() >= BATCH_SIZE:
		for cell in cells:
			set_walkable_cell(cell)
			add_surrounding_walls(cell)
		cells.clear()

func add_surrounding_walls(cell: Vector2i) -> void:
	for dir in DIRECTIONS:
		var check_pos = cell + dir
		if not is_walkable_tile(check_pos):
			set_wall_cell(check_pos)

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
	for item in items.get_children():
		item.queue_free()
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

func calculate_items_per_room(room_size: Vector2) -> int:
	var area = room_size.x * room_size.y
	var min_area = INF
	var max_area = 0.0
	
	for room in rooms.get_children():
		var room_area = room.size.x * room.size.y
		min_area = min(min_area, room_area)
		max_area = max(max_area, room_area)
	
	var normalized_area = inverse_lerp(min_area, max_area, area)
	
	return round(lerp(MIN_ITEMS_PER_ROOM, MAX_ITEMS_PER_ROOM, normalized_area))

func get_valid_pos_in_room(room: Node) -> Vector2:
	var half_size = room.size
	var room_rect = Rect2(
		room.position - half_size + Vector2(MIN_EDGE_PADDING, MIN_EDGE_PADDING),
		half_size * 2 - Vector2(MIN_EDGE_PADDING * 2, MIN_EDGE_PADDING * 2)
		)
	var pos = Vector2(
		randf_range(room_rect.position.x, room_rect.position.x + room_rect.size.x),
		randf_range(room_rect.position.y, room_rect.position.y + room_rect.size.y)
		)
		
	return pos

func distribute_items() -> void:
	set_phase("ITEMS")
	
	for item in items.get_children():
		item.queue_free()
	
	var rooms_to_process = rooms.get_children()
	var total_items = 0
	
	# First pass to calculate total items
	for room in rooms_to_process:
		total_items += calculate_items_per_room(room.size)
	
	items_to_process = total_items
	items_processed = 0
	var current_batch = []
	
	for room in rooms_to_process:
		var num_items = calculate_items_per_room(room.size)
		
		for i in range(num_items):
			current_batch.append({
				"room": room,
				"position": get_valid_pos_in_room(room)
			})
			
			if current_batch.size() >= ITEMS_BATCH_SIZE:
				await process_item_batch(current_batch)
				items_processed += current_batch.size()
				update_progress()
				current_batch.clear()
				await get_tree().process_frame
	
	if current_batch:
		await process_item_batch(current_batch)
		items_processed += current_batch.size()
		update_progress()

func process_item_batch(batch: Array) -> void:
	for item_data in batch:
		var item = MimicManager.instantiate_random_mimic()
		if item:
			items.add_child(item)
			item.position = item_data.position
		
	await get_tree().process_frame

func set_phase(phase: String) -> void:
	current_phase = phase
	items_processed = 0
	generation_phase_changed.emit(PHASES[phase])
	generation_phase_color.emit(PHASE_COLORS[phase])

func update_progress() -> void:
	var progress = float(items_processed) / float(items_to_process) * 100
	generation_progress_updated.emit(PHASES[current_phase], progress)
