extends PanelContainer

var panel_height: int = 100  # Base height
var panel_width: int = 150   # Base width
@onready var sub_viewport: SubViewport = $SubViewport
@onready var vbox: VBoxContainer = $Vbox
@onready var preview: TextureRect = $Vbox/Preview
@onready var label: Label = $Vbox/Label

signal enemy_selected(enemy_path: String)
var enemy_instance: Node
var enemy_path: String

var normal_color = Color.LIGHT_SLATE_GRAY
var hover_color = Color.LIGHT_CORAL

func _ready():
	# Make the panel size match our desired dimensions
	custom_minimum_size = Vector2(panel_width, panel_height + 30)  # Extra 30 pixels for label
	sub_viewport.size = Vector2i(panel_width, panel_height)
	preview.custom_minimum_size = Vector2(panel_width, panel_height)
	
	# Set up the label
	label.add_theme_font_size_override("font_size", 16)  # Increased font size
	label.custom_minimum_size = Vector2(0, 30)  # Ensure label has space
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	
	# Set up panel style
	add_theme_stylebox_override("panel", get_panel_style(normal_color))

func get_panel_style(color: Color) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	return style

func load_enemy(path: String):
	enemy_path = path
	var enemy_scene = load(path)
	enemy_instance = enemy_scene.instantiate()
	
	# Center the enemy in the viewport
	if enemy_instance is Node2D:
		enemy_instance.position = Vector2(panel_width/2, panel_height/2)
		
		# Scale the sprite appropriately for the viewport size
		if enemy_instance.has_node("AnimatedSprite2D"):
			var sprite = enemy_instance.get_node("AnimatedSprite2D")
			var sprite_size = sprite.sprite_frames.get_frame_texture("idle", 0).get_size()
			# Calculate scale factor based on both width and height, maintaining aspect ratio
			var scale_factor = min(
				(panel_width * 0.8) / sprite_size.x,
				(panel_height * 0.8) / sprite_size.y
			)
			sprite.scale = Vector2(scale_factor, scale_factor)
	
	sub_viewport.add_child(enemy_instance)
	preview.texture = sub_viewport.get_texture()
	
	# Set label text and ensure it fits
	var enemy_name = path.get_file().get_basename()
	enemy_name = enemy_name.replace("_", " ").capitalize()
	label.text = enemy_name
	
	# Setup mouse interaction
	gui_input.connect(_on_panel_input)
	mouse_entered.connect(_on_panel_mouse_entered)
	mouse_exited.connect(_on_panel_mouse_exited)
	
	sub_viewport.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

func _on_panel_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		enemy_selected.emit(enemy_path)

func _on_panel_mouse_entered():
	add_theme_stylebox_override("panel", get_panel_style(hover_color))
	if enemy_instance:
		enemy_instance.animate_enemy()

func _on_panel_mouse_exited():
	add_theme_stylebox_override("panel", get_panel_style(normal_color))
	if enemy_instance and enemy_instance.has_node("AnimatedSprite2D"):
		var sprite = enemy_instance.get_node("AnimatedSprite2D")
		sprite.play("idle")
