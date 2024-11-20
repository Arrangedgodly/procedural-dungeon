extends Enemy
class_name MiniDevil

func _ready() -> void:
	health = 10
	damage = 15
	speed = 400

func attack_player() -> void:
	sprite.play("attack")
