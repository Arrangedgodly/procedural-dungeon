extends MeleeEnemy
class_name MediumDevil

func _ready() -> void:
	health = 50
	speed = 250
	damage = 15

func attack_player() -> void:
	sprite.play("attack")
