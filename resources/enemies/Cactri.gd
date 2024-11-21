extends Enemy
class_name Cactri

var is_attacking: bool = false
var spike_distance: float = 8.0

func _ready() -> void:
	health = 30
	speed = 30
	damage = 50
	approach_range = 500
	attack_range = 30

func attack_player() -> void:
	sprite.play("attack")
