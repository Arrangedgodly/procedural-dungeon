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
	if !can_attack or !target:
		return
	
	can_attack = false
		
	sprite.play("attack")
	await sprite.animation_finished
	sprite.play("idle")
	
	var fireball = FIREBALL.instantiate()
	fireball.set_damage(damage)
	add_child(fireball)
	fireball.global_position = global_position
	fireball.launch(target.global_position)
	fireball.despawning.connect(set_can_attack)

func set_can_attack() -> void:
	can_attack = true
