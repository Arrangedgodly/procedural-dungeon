extends Node2D

@onready var gurpy: HBoxContainer = $VBoxContainer/Gurpy
@onready var games: HBoxContainer = $VBoxContainer/Games
@onready var font_timer: Timer = $FontTimer
@onready var intro_timer: Timer = $IntroTimer
@export var intro_sound: AudioStream
@onready var color_rect: ColorRect = $ColorRect2

var letters = []
var fonts = []
var colors = [
   Color("#FF0000"),
   Color("#00FF00"),
   Color("#0000FF"),
   Color("#FFFF00"),
   Color("#FF00FF"),
   Color("#00FFFF"),
   Color("#FFA500"),
   Color("#800080"),
   Color("#FF69B4"),
   Color("#00FF7F"),
   Color("#FF4500"),
   Color("#1E90FF"),
   Color("#FFD700"),
   Color("#32CD32"),
   Color("#8A2BE2"),
   Color("#FF1493"),
   Color("#7CFC00"),
   Color("#FF8C00"),
   Color("#DC143C"),
   Color("#9400D3"),
   Color("#00CED1"),
   Color("#FF69B4"),
   Color("#4169E1"),
   Color("#98FB98"),
   Color("#DDA0DD"),
   Color("#F08080"),
   Color("#9370DB"),
   Color("#FFB6C1"),
   Color("#20B2AA"),
   Color("#48D1CC")
]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		SoundManager.stop(intro_sound)
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _ready() -> void:
	load_fonts()
	
	for letter in gurpy.get_children():
		letters.append(letter)
	for letter in games.get_children():
		letters.append(letter)
		
	intro_timer.start()
	intro_timer.timeout.connect(_on_intro_timer_timeout)
	
	font_timer.timeout.connect(randomize_appearance)
	
	SoundManager.play_sfx(intro_sound, "Player", self.global_position)
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0, 1.5)
	await tween.finished
	await get_tree().create_timer(1).timeout
	SoundManager.play_sfx(intro_sound, "Player", self.global_position)
	await get_tree().create_timer(.75).timeout
	var finish_tween = create_tween()
	finish_tween.tween_property(color_rect, "modulate:a", 1, 2.5)
	
func load_fonts() -> void:
	var dir = DirAccess.open("res://assets/fonts/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".ttf") or file_name.ends_with(".otf"):
				var font = load("res://assets/fonts/" + file_name)
				if font:
					fonts.append(font)
			file_name = dir.get_next()
		
		dir.list_dir_end()

func randomize_appearance() -> void:
	for letter in letters:
		if fonts.size() > 0:
			var random_font = fonts.pick_random()
			var random_color = colors.pick_random()
			letter.add_theme_font_override("font", random_font)
			letter.add_theme_color_override("font_color", random_color)
			
func _on_intro_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
