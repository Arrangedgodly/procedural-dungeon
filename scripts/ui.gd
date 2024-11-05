extends Control
signal settings_updated(settings: Dictionary)
signal trigger_generate_map
signal trigger_generate_layers

@onready var rooms_generated_spin_box: SpinBox = $HBoxContainer/RoomsGenerated/RoomsGeneratedSpinBox
@onready var min_size_spin_box: SpinBox = $HBoxContainer/MinSize/MinSizeSpinBox
@onready var max_size_spin_box: SpinBox = $HBoxContainer/MaxSize/MaxSizeSpinBox
@onready var horizontal_spread_spin_box: SpinBox = $HBoxContainer/HorizontalSpread/HorizontalSpreadSpinBox
@onready var corridor_width_spin_box: SpinBox = $HBoxContainer/CorridorWidth/CorridorWidthSpinBox
@onready var apply: Button = $HBoxContainer/Apply
@onready var generate_new_map: Button = $HBoxContainer2/GenerateNewMap
@onready var generate_new_texture: Button = $HBoxContainer2/GenerateNewTexture
var dungeon_size: DungeonSize

func setup_ui() -> void:
	var constraints = DungeonSize.PROPERTY_CONSTRAINTS
	
	#Room Count
	rooms_generated_spin_box.min_value = constraints.rooms_generated.min
	rooms_generated_spin_box.max_value = constraints.rooms_generated.max
	rooms_generated_spin_box.step = 1
	
	#Min Size
	min_size_spin_box.min_value = constraints.min_size.min
	min_size_spin_box.max_value = constraints.min_size.max
	min_size_spin_box.step = 1
	
	#Max Size
	max_size_spin_box.min_value = constraints.max_size.min
	max_size_spin_box.max_value = constraints.max_size.max
	max_size_spin_box.step = 1
	
	#Horizontal Spread
	horizontal_spread_spin_box.min_value = constraints.horizontal_spread.min
	horizontal_spread_spin_box.max_value = constraints.horizontal_spread.max
	horizontal_spread_spin_box.step = 50
	
	#Corridor Width
	corridor_width_spin_box.min_value = constraints.corridor_width.min
	corridor_width_spin_box.max_value = constraints.corridor_width.max
	corridor_width_spin_box.step = 1

func connect_signals() -> void:
	# Connect UI element value changes to DungeonSize
	rooms_generated_spin_box.value_changed.connect(
		func(value): dungeon_size.rooms_generated = value
	)
	min_size_spin_box.value_changed.connect(
		func(value): dungeon_size.min_size = value
	)
	max_size_spin_box.value_changed.connect(
		func(value): dungeon_size.max_size = value
	)
	horizontal_spread_spin_box.value_changed.connect(
		func(value): dungeon_size.horizontal_spread = value
	)
	corridor_width_spin_box.value_changed.connect(
		func(value): dungeon_size.corridor_width = value
	)

	# Connect DungeonSize changes back to UI
	if dungeon_size:
		dungeon_size.value_changed.connect(_on_dungeon_size_changed)

func load_current_settings() -> void:
	if not dungeon_size:
		return
	
	rooms_generated_spin_box.value = dungeon_size.rooms_generated
	min_size_spin_box.value = dungeon_size.min_size
	max_size_spin_box.value = dungeon_size.max_size
	horizontal_spread_spin_box.value = dungeon_size.horizontal_spread
	corridor_width_spin_box.value = dungeon_size.corridor_width

func set_dungeon_size(new_dungeon_size: DungeonSize):
	dungeon_size = new_dungeon_size
	setup_ui()
	load_current_settings()
	connect_signals()

func _on_dungeon_size_changed(property: String, value: Variant) -> void:
	match property:
		"rooms_generated":
			rooms_generated_spin_box.value = value
		"min_size":
			min_size_spin_box.value = value
		"max_size":
			max_size_spin_box.value = value
		"horizontal_spread":
			horizontal_spread_spin_box.value = value
		"corridor_width":
			corridor_width_spin_box.value = value


func _on_generate_new_map_pressed() -> void:
	trigger_generate_map.emit()


func _on_generate_new_texture_pressed() -> void:
	trigger_generate_layers.emit()
