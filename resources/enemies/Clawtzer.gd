extends MeleeEnemy
class_name Clawtzer

func _ready() -> void:
	health = 35
	speed = 350
	damage = 20

func attack_player() -> void:
	sprite.play("attack")
