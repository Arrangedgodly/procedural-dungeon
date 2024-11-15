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
		
	if sprite:
		sprite.play("attack")
		await sprite.animation_finished
		sprite.play("idle")
	
	var fireball = FIREBALL.instantiate()
	fireball.set_damage(damage)
	get_tree().current_scene.add_child(fireball)
	
	var spawn_pos = global_position
	fireball.launch(target.global_position)
	
	can_attack = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
