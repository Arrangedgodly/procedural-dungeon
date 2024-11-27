extends Enemy
class_name RangedEnemy

func _ready() -> void:
	keep_distance = true
	super._ready()

func attack_player() -> void:
	sprite.play("attack")
	attack_timer.start()
