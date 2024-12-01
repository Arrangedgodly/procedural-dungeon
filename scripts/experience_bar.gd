extends Control
class_name ExperienceBar

@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var level_label: Label = $LevelLabel
@onready var xp_label: Label = $XPLabel

var current_xp: int = 0
var current_level: int = 1
var target_xp: int = 0
var is_animating: bool = false

const BASE_XP: int = 100
const LEVEL_MULTIPLIER: float = 1.25

func _ready() -> void:
	setup_initial_values()
	update_labels()

func setup_initial_values() -> void:
	progress_bar.max_value = get_xp_for_next_level()
	progress_bar.value = 0

func get_xp_for_next_level() -> int:
	return int(BASE_XP * pow(LEVEL_MULTIPLIER, current_level - 1))

func add_experience(amount: int) -> void:
	current_xp += amount
	var next_level = get_xp_for_next_level()
	var excess_xp = 0
	if current_xp >= next_level:
		if current_xp > next_level:
			excess_xp = current_xp - next_level

		progress_bar.value = next_level
		level_up()
		await get_tree().create_timer(.25).timeout
		add_experience(excess_xp)
	else:
		progress_bar.value = current_xp
		
	update_labels()

func level_up() -> void:
	current_level += 1
	current_xp = 0
	progress_bar.value = 0
	update_labels()

func update_labels() -> void:
	level_label.text = "Level " + str(current_level)
	xp_label.text = str(current_xp) + " / " + str(get_xp_for_next_level()) + " XP"
