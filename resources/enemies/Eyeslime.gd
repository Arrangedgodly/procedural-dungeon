extends MeleeEnemy
class_name Eyeslime

func _ready() -> void:
	health = 15
	speed = 75
	damage = 5

func attack_player() -> void:
	sprite.play("attack")
