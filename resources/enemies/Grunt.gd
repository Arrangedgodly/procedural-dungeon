extends MeleeEnemy
class_name Grunt

var combo_hits: int = 0
var max_combo_hits: int = 4
var hit_delay: float = 0.1

const BITE_EFFECT = preload("res://scenes/effects/bite.tscn")

func _ready() -> void:
	health = 25
	speed = 200
	damage = 10
	attack_range = 25
	approach_range = 200
	super._ready()

func attack_player() -> void:
	super.attack_player()
	
	combo_hits = 0
	perform_combo_attack()

func perform_combo_attack() -> void:
	if combo_hits < max_combo_hits and target and get_distance_to_player() <= attack_range:
		var lunge_dir = (target.global_position - global_position).normalized()
		velocity = lunge_dir * speed * 0.5
		move_and_slide()
		
		sprite.play("attack")
		var bite = BITE_EFFECT.instantiate()
		get_tree().get_first_node_in_group("effects").add_child(bite)
		var bite_offset = get_sprite_content_center() + (lunge_dir * attack_range)
		bite.update_position(bite_offset)
		await sprite.animation_finished
		
		if target and get_distance_to_player() <= attack_range:
			target.take_damage(damage)
			
		combo_hits += 1
		
		await get_tree().create_timer(hit_delay).timeout
		perform_combo_attack()
	else:
		velocity = Vector2.ZERO
		attack_timer.start()
