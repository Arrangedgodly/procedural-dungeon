extends Control

var current_page = "normal" # "normal" or "boss"
var current_page_index = 0
var enemies_per_page = 20
var all_enemy_paths = []
var enemy_buttons = []

@onready var grid_container: GridContainer = $MainContainer/GridContainer
@onready var swap_pages: Button = $MainContainer/SwapPages
@onready var label: Label = $MainContainer/Label
@onready var pagination_container: HBoxContainer = $MainContainer/PaginationContainer
@onready var prev_button: Button = $MainContainer/PaginationContainer/PrevButton
@onready var next_button: Button = $MainContainer/PaginationContainer/NextButton
@onready var page_label: Label = $MainContainer/PaginationContainer/PageLabel

const EnemyPanel = preload("res://scenes/enemy_panel.tscn")

func _ready() -> void:
	# Set up grid for smaller tiles
	grid_container.columns = 5  # More columns for smaller tiles
	grid_container.add_theme_constant_override("h_separation", 10)
	grid_container.add_theme_constant_override("v_separation", 10)
	
	# Connect signals
	swap_pages.pressed.connect(_on_swap_pages_pressed)
	prev_button.pressed.connect(_on_prev_page_pressed)
	next_button.pressed.connect(_on_next_page_pressed)
	
	load_enemy_paths()
	update_page_display()

func load_enemy_paths() -> void:
	all_enemy_paths.clear()
	
	var path = "res://scenes/enemies/"
	if current_page == "boss":
		path += "bosses/"
	
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".tscn"):
				all_enemy_paths.append(path + file_name)
			file_name = dir.get_next()
			
		dir.list_dir_end()
	
	current_page_index = 0
	display_current_page()

func display_current_page() -> void:
	# Clear existing buttons
	for button in enemy_buttons:
		button.queue_free()
	enemy_buttons.clear()
	
	var start_index = current_page_index * enemies_per_page
	var end_index = min(start_index + enemies_per_page, all_enemy_paths.size())
	
	for i in range(start_index, end_index):
		create_enemy_tile(all_enemy_paths[i])
	
	update_page_display()

func create_enemy_tile(enemy_path: String):
	var panel = EnemyPanel.instantiate()
	grid_container.add_child(panel)
	panel.load_enemy(enemy_path)
	panel.enemy_selected.connect(_on_enemy_selected)
	enemy_buttons.append(panel)

func update_page_display():
	var total_pages = ceili(float(all_enemy_paths.size()) / enemies_per_page)
	page_label.text = "Page %d/%d" % [current_page_index + 1, total_pages]
	
	# Update button states
	prev_button.disabled = current_page_index <= 0
	next_button.disabled = current_page_index >= total_pages - 1 or total_pages <= 1

func _on_prev_page_pressed():
	if current_page_index > 0:
		current_page_index -= 1
		display_current_page()

func _on_next_page_pressed():
	var total_pages = ceili(float(all_enemy_paths.size()) / enemies_per_page)
	if current_page_index < total_pages - 1:
		current_page_index += 1
		display_current_page()

func _on_swap_pages_pressed():
	current_page = "boss" if current_page == "normal" else "normal"
	swap_pages.text = "Switch to Normal Selection" if current_page == "boss" else "Switch to Boss Selection"
	current_page_index = 0
	load_enemy_paths()

func _on_enemy_selected(enemy_path: String):
	print("Selected enemy: ", enemy_path)
	# Implement combat scene loading here
