extends Enemy
class_name Blitzer

func _ready() -> void:
	health = 30
	speed = 750
	damage = 20
	sprite.sprite_frames.set_animation_loop("attack", true)
