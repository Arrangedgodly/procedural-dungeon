extends MeleeEnemy
class_name Cactri

var spike_distance: float = 8.0
var radius: int

func _ready() -> void:
	health = 30
	speed = 30
	damage = 50
	approach_range = 500
	radius = approach_range / 2
	attack_range = 30
	super._ready()

func attack_player() -> void:
	sprite.play("attack")
