extends Enemy
class_name Doggone

func _ready() -> void:
	health = 10
	speed = 150
	damage = 5

func attack_player() -> void:
	sprite.play("attack")
