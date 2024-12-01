extends Pickup
class_name ExperienceGem

var experience_value: int = randi_range(1, 3)

func _ready() -> void:
	super._ready()

func can_be_collected(_player: Player) -> bool:
	return true

func collect(player: Player) -> bool:
	player.gain_experience(experience_value)
	play_sfx(player)
	return true
