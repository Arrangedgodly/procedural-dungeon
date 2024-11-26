extends MeleeEnemy
class_name MiniSlime

func _ready() -> void:
	health = 10
	speed = 75
	damage = 5

func attack_player() -> void:
	sprite.play("attack")
