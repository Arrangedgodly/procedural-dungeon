extends Node2D
@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var intro_timer: Timer = $IntroTimer
@export var boot_sound: AudioStream

func _ready() -> void:
	intro_timer.start()
	await get_tree().create_timer(.5).timeout
	SoundManager.play_sfx(boot_sound, "Player", self.global_position)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		SoundManager.stop(boot_sound)
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_intro_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
