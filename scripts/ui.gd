extends Control
signal trigger_generate_map
signal trigger_generate_layers

@onready var rooms_generated_spin_box: SpinBox = $HBoxContainer/RoomsGenerated/RoomsGeneratedSpinBox
@onready var min_size_spin_box: SpinBox = $HBoxContainer/MinSize/MinSizeSpinBox
@onready var max_size_spin_box: SpinBox = $HBoxContainer/MaxSize/MaxSizeSpinBox
@onready var horizontal_spread_spin_box: SpinBox = $HBoxContainer/HorizontalSpread/HorizontalSpreadSpinBox
@onready var corridor_width_spin_box: SpinBox = $HBoxContainer/CorridorWidth/CorridorWidthSpinBox
@onready var generate_new_map: Button = $HBoxContainer2/GenerateNewMap
@onready var generate_new_texture: Button = $HBoxContainer2/GenerateNewTexture

var dungeon_size: DungeonSize

func _ready() -> void:
	generate_new_map.disabled = false
	generate_new_map.focus_mode = Control.FOCUS_CLICK
	generate_new_texture.disabled = false
	generate_new_texture.focus_mode = Control.FOCUS_CLICK

func setup_ui() -> void:
	var constraints = DungeonSize.PROPERTY_CONSTRAINTS
	
	# Setup spin boxes with constraints
	var spin_boxes = {
		"rooms_generated": rooms_generated_spin_box,
		"min_size": min_size_spin_box,
		"max_size": max_size_spin_box,
		"horizontal_spread": horizontal_spread_spin_box,
		"corridor_width": corridor_width_spin_box
	}
	
	for property_name in spin_boxes:
		var spin_box = spin_boxes[property_name]
		var constraint = constraints[property_name]
		
		spin_box.min_value = constraint.min
		spin_box.max_value = constraint.max
		spin_box.value = constraint.default
		spin_box.step = 1 if property_name != "horizontal_spread" else 50

func connect_signals() -> void:
	if not dungeon_size:
		return
		
	# Connect all spin boxes to update dungeon_size directly
	var spin_box_connections = {
		rooms_generated_spin_box: "rooms_generated",
		min_size_spin_box: "min_size",
		max_size_spin_box: "max_size",
		horizontal_spread_spin_box: "horizontal_spread",
		corridor_width_spin_box: "corridor_width"
	}
	
	for spin_box in spin_box_connections:
		var property = spin_box_connections[spin_box]
		# Disconnect existing connections if any
		if spin_box.value_changed.is_connected(
			func(value): dungeon_size.set_value(property, value)
		):
			spin_box.value_changed.disconnect(
				func(value): dungeon_size.set_value(property, value)
			)
		# Connect new signal
		spin_box.value_changed.connect(
			func(value): dungeon_size.set_value(property, value)
		)

func load_current_settings() -> void:
	if not dungeon_size:
		return
	
	# Load current values from dungeon_size
	rooms_generated_spin_box.value = dungeon_size.rooms_generated
	min_size_spin_box.value = dungeon_size.min_size
	max_size_spin_box.value = dungeon_size.max_size
	horizontal_spread_spin_box.value = dungeon_size.horizontal_spread
	corridor_width_spin_box.value = dungeon_size.corridor_width

func set_dungeon_size(new_dungeon_size: DungeonSize) -> void:
	dungeon_size = new_dungeon_size
	setup_ui()
	connect_signals()
	load_current_settings()

func _on_generate_new_map_pressed() -> void:
	trigger_generate_map.emit()
	generate_new_texture.disabled = true
	generate_new_texture.focus_mode = Control.FOCUS_NONE

func _on_generate_new_texture_pressed() -> void:
	trigger_generate_layers.emit()

func _on_basic_dungeon_map_generation_finished() -> void:
	generate_new_map.disabled = false
	generate_new_map.focus_mode = Control.FOCUS_CLICK
	generate_new_texture.disabled = false
	generate_new_texture.focus_mode = Control.FOCUS_CLICK

func _on_basic_dungeon_map_generation_started() -> void:
	generate_new_map.disabled = true
	generate_new_map.focus_mode = Control.FOCUS_NONE

func _on_basic_dungeon_texture_generated() -> void:
	generate_new_texture.disabled = true
	generate_new_texture.focus_mode = Control.FOCUS_NONE
