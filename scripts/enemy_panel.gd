extends PanelContainer

signal enemy_selected(enemy_path: String)

@onready var sub_viewport: SubViewport = $SubViewport
@onready var vbox: VBoxContainer = $Vbox
@onready var preview: TextureRect = $Vbox/Preview
@onready var label: Label = $Vbox/Label
@onready var background: TextureRect = $Background

var panel_height: int = 200
var panel_width: int = 200
var enemy_instance: Node
var enemy_path: String
var is_ready: bool = false

@onready var normal_texture = preload("res://assets/ui/Book UI V1/Sprites/Content/Titles and Underlying/19.png")
@onready var hover_texture = preload("res://assets/ui/Book UI V1/Sprites/Content/Titles and Underlying/21_1.png")
@onready var normal_label_texture = preload("res://assets/ui/Book UI V1/Sprites/Content/Titles and Underlying/18.png")
@onready var hover_label_texture = preload("res://assets/ui/Book UI V1/Sprites/Content/Titles and Underlying/21_4.png")

func _ready():
	custom_minimum_size = Vector2(panel_width, panel_height + 30)
	sub_viewport.size = Vector2i(panel_width, panel_height)
	
	background.texture = normal_texture
	background.custom_minimum_size = Vector2(panel_width, panel_height)
	
	preview.custom_minimum_size = Vector2(panel_width, panel_height)
	
	label.add_theme_font_size_override("font_size", 24)
	label.custom_minimum_size = Vector2(0, 30)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.add_theme_stylebox_override("normal", get_label_style(normal_label_texture))
	
	is_ready = true

func load_enemy(path: String):
	enemy_path = path
	if is_ready:
		_load_enemy_instance()
	else:
		# Wait for ready if not ready yet
		await ready
		_load_enemy_instance()

func _load_enemy_instance() -> void:
	var enemy_scene = load(enemy_path)
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
	var enemy_name = enemy_path.get_file().get_basename()
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
	background.texture = hover_texture
	label.add_theme_stylebox_override("normal", get_label_style(hover_label_texture))
	if enemy_instance:
		enemy_instance.animate_enemy()

func _on_panel_mouse_exited():
	background.texture = normal_texture
	label.add_theme_stylebox_override("normal", get_label_style(normal_label_texture))
	if enemy_instance and enemy_instance.has_node("AnimatedSprite2D"):
		var sprite = enemy_instance.get_node("AnimatedSprite2D")
		sprite.play("idle")

func get_label_style(texture: Texture2D) -> StyleBoxTexture:
	var style = StyleBoxTexture.new()
	style.texture = texture
	return style
