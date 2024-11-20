extends Node2D
@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var intro_timer: Timer = $IntroTimer

func _ready() -> void:
	intro_timer.start()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _process(delta: float) -> void:
	if video_stream_player.is_playing():
		return
	else:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_intro_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
