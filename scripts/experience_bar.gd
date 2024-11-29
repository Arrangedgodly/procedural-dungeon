extends Control
class_name ExperienceBar

@onready var progress_bar: TextureProgressBar = $ProgressBar
@onready var level_label: Label = $LevelLabel
@onready var xp_label: Label = $XPLabel
@onready var level_up_particles: GPUParticles2D = $LevelUpParticles
@onready var animation_player: AnimationPlayer = $AnimationPlayer

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
	level_up_particles.emitting = false

func get_xp_for_next_level() -> int:
	return int(BASE_XP * pow(LEVEL_MULTIPLIER, current_level - 1))

func add_experience(amount: int) -> void:
	target_xp = current_xp + amount
	if !is_animating:
		animate_xp_gain()

func animate_xp_gain() -> void:
	is_animating = true
	
	while current_xp < target_xp:
		var xp_needed = get_xp_for_next_level()
		var xp_remaining = target_xp - current_xp
		
		# If we have enough XP to level up
		if current_xp + xp_remaining >= xp_needed:
			# Fill to max
			var tween = create_tween()
			tween.tween_property(progress_bar, "value", xp_needed, 0.5)
			await tween.finished
			
			# Level up!
			level_up()
			
			# Calculate remaining XP after level up
			current_xp = current_xp + xp_remaining - xp_needed
			target_xp = target_xp - xp_needed
			progress_bar.max_value = get_xp_for_next_level()
			progress_bar.value = current_xp
		else:
			# Just add the XP
			var tween = create_tween()
			current_xp += xp_remaining
			tween.tween_property(progress_bar, "value", current_xp, 0.5)
			await tween.finished
			break
	
	update_labels()
	is_animating = false

func level_up() -> void:
	current_level += 1
	animation_player.play("level_up")
	level_up_particles.emitting = true
	update_labels()

func update_labels() -> void:
	level_label.text = "Level " + str(current_level)
	xp_label.text = str(current_xp) + " / " + str(get_xp_for_next_level()) + " XP"
