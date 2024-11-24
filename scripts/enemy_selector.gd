extends Control

var current_page = "normal" # "normal" or "boss"
var current_page_index = 0
var enemies_per_page = 8
var all_enemy_paths = []
var enemy_buttons = []
@onready var next_button: Button = $NextButton
@onready var prev_button: Button = $PrevButton
@onready var boss_tab: Button = $BossTab
@onready var enemy_tab: Button = $EnemyTab
@onready var left_page: GridContainer = $LeftPage
@onready var right_page: GridContainer = $RightPage
@onready var camera_2d: Camera2D = $Camera2D
@onready var book: AnimatedSprite2D = $Book

const EnemyPanel = preload("res://scenes/enemy_panel.tscn")
const EnemyConfigPopup = preload("res://scenes/enemy_config_popup.tscn")
const PAGE_MARGIN = Vector2(40, 40)
const PAGE_SIZE = Vector2(500, 560)
const PANELS_PER_ROW = 2
const PANELS_PER_COLUMN = 2
const PANELS_PER_PAGE = PANELS_PER_ROW * PANELS_PER_COLUMN
const ACTIVE_COLOR = Color.WHITE
const INACTIVE_COLOR = Color.DIM_GRAY

func _ready() -> void:
	setup_book_layout()
	
	prev_button.pressed.connect(_on_prev_page_pressed)
	next_button.pressed.connect(_on_next_page_pressed)
	boss_tab.pressed.connect(_on_boss_tab_pressed)
	enemy_tab.pressed.connect(_on_enemy_tab_pressed)
	
	update_tab_appearance()
	
	load_enemy_paths()
	update_page_display()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

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
	# Clear existing enemies
	for button in enemy_buttons:
		button.queue_free()
	enemy_buttons.clear()
	
	book.play("idle")
	
	var start_index = current_page_index * enemies_per_page
	var end_index = min(start_index + enemies_per_page, all_enemy_paths.size())
	
	# Calculate enemies for each page
	var enemies_per_side = PANELS_PER_PAGE  # 6 enemies per page (2x3 grid)
	for i in range(start_index, end_index):
		var enemy_path = all_enemy_paths[i]
		var panel = create_enemy_tile(enemy_path)
		
		# Place on left or right page based on index
		if i < start_index + enemies_per_side:
			left_page.add_child(panel)
		else:
			right_page.add_child(panel)
	
	update_page_display()

func create_enemy_tile(enemy_path: String) -> Node:
	var panel = EnemyPanel.instantiate()
	panel.load_enemy(enemy_path)
	panel.enemy_selected.connect(_on_enemy_selected)
	enemy_buttons.append(panel)
	return panel

func update_page_display():
	var total_pages = ceili(float(all_enemy_paths.size()) / enemies_per_page)
	prev_button.disabled = current_page_index <= 0
	next_button.disabled = current_page_index >= total_pages - 1 or total_pages <= 1

func _on_prev_page_pressed():
	if current_page_index > 0:
		current_page_index -= 1
		handle_page_turn_start()
		book.play("flip_backward")
		await book.animation_finished
		book.play("idle")
		display_current_page()
		handle_page_turn_end()

func _on_next_page_pressed():
	var total_pages = ceili(float(all_enemy_paths.size()) / enemies_per_page)
	if current_page_index < total_pages - 1:
		current_page_index += 1
		handle_page_turn_start()
		book.play("flip_forward")
		await book.animation_finished
		book.play("idle")
		display_current_page()
		handle_page_turn_end()

func _on_enemy_selected(enemy_path: String):
	var popup = EnemyConfigPopup.instantiate()
	popup.position = get_viewport_rect().size / 2 - popup.size / 2
	add_child(popup)
	popup.setup(enemy_path)
	popup.config_confirmed.connect(_on_config_confirmed)

func _on_config_confirmed(enemy_path: String, count: int, variants: Array) -> void:
	get_tree().get_root().set_meta("selected_enemy_path", enemy_path)
	get_tree().get_root().set_meta("enemy_count", count)
	get_tree().get_root().set_meta("enemy_variants", variants)
	get_tree().change_scene_to_file("res://scenes/test_arena.tscn")

func setup_book_layout() -> void:
	# Setup grid containers for each page
	for grid in [left_page, right_page]:
		grid.columns = PANELS_PER_ROW
		grid.add_theme_constant_override("h_separation", 15)
		grid.add_theme_constant_override("v_separation", 10)

func update_tab_appearance() -> void:
	if current_page == "boss":
		boss_tab.add_theme_color_override("font_color", ACTIVE_COLOR)
		enemy_tab.add_theme_color_override("font_color", INACTIVE_COLOR)
	else:
		boss_tab.add_theme_color_override("font_color", INACTIVE_COLOR)
		enemy_tab.add_theme_color_override("font_color", ACTIVE_COLOR)

func _on_boss_tab_pressed() -> void:
	if current_page != "boss":
		current_page = "boss"
		handle_page_turn_start()
		book.play("flip_forward")
		await book.animation_finished
		update_tab_appearance()
		current_page_index = 0
		load_enemy_paths()
		handle_page_turn_end()

func _on_enemy_tab_pressed() -> void:
	if current_page != "normal":
		current_page = "normal"
		handle_page_turn_start()
		book.play("flip_backward")
		await book.animation_finished
		update_tab_appearance()
		current_page_index = 0
		load_enemy_paths()
		handle_page_turn_end()

func handle_page_turn_start() -> void:
	left_page.hide()
	right_page.hide()
	prev_button.hide()
	next_button.hide()
	
func handle_page_turn_end() -> void:
	left_page.show()
	right_page.show()
	prev_button.show()
	next_button.show()
