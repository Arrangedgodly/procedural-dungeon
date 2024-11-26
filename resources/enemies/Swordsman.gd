extends MeleeEnemy
class_name Swordsman

func _ready() -> void:
	health = 40
	speed = 150
	damage = 20

func attack_player() -> void:
	sprite.play("attack")
