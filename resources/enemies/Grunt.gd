extends Enemy
class_name Grunt

func _ready() -> void:
	health = 25
	speed = 200
	damage = 10

func attack_player() -> void:
	sprite.play("attack")
