extends Enemy
class_name MediumCyclops

func _ready() -> void:
	health = 200
	speed = 200
	damage = 30

func attack_player() -> void:
	sprite.play("attack")
