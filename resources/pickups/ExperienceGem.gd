extends Pickup
class_name ExperienceGem

var experience_value: int = randi_range(1, 3)

func _ready() -> void:
	super._ready()
	print(self.name + " is worth " + str(experience_value) + " experience")

func can_be_collected(_player: Player) -> bool:
	return true

func collect(player: Player) -> bool:
	print("Player gaining experience")
	player.gain_experience(experience_value)
	return true
