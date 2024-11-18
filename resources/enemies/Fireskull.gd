extends Enemy
class_name Fireskull

const FIREBALL = preload("res://scenes/projectiles/fireball.tscn")

func _ready() -> void:
	health = 75
	speed = 50
	damage = 30
	approach_range = 500
	attack_range = 100

func attack_player() -> void:
	if !can_attack or !target or !attack_cooldown_timer.is_stopped():
		return
	
	can_attack = false
	sprite.play("attack")
	sprite.animation_finished.connect(_idle_sprite)
	
	var fireball = FIREBALL.instantiate()
	fireball.set_damage(damage)
	add_child(fireball)
	fireball.global_position = global_position
	fireball.launch(target.global_position)
	attack_cooldown_timer.start()
	attack_cooldown_timer.timeout.connect(set_can_attack)

func set_can_attack() -> void:
	can_attack = true
	attack_cooldown_timer.timeout.disconnect(set_can_attack)

func _idle_sprite() -> void:
	sprite.play("idle")
	sprite.animation_finished.disconnect(_idle_sprite)
