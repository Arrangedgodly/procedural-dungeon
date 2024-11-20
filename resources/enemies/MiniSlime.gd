extends Enemy
class_name MiniSlime

func _ready() -> void:
	health = 10
	speed = 400
	damage = 5

func attack_player() -> void:
	sprite.play("attack")
