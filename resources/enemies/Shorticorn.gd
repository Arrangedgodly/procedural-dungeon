extends Enemy
class_name Shorticorn

func _ready() -> void:
	health = 50
	speed = 100
	damage = 15

func attack_player() -> void:
	sprite.play("attack")
