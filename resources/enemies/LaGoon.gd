extends Enemy
class_name LaGoon

func _ready() -> void:
	health = 25
	speed = 200
	damage = 10

func attack_player() -> void:
	sprite.play("attack")
