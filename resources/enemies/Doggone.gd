extends MeleeEnemy
class_name Doggone

const BITE_EFFECT = preload("res://scenes/effects/bite.tscn")

func _ready() -> void:
	health = 10
	speed = 150
	damage = 10
	attack_range = 18
	approach_range = 400
	super._ready()

func attack_player() -> void:
	if target and get_distance_to_player() <= attack_range:
		var attack_dir = (target.global_position - global_position).normalized()
		sprite.flip_h = attack_dir.x < 0
		
		sprite.play("attack")
		await sprite.animation_finished
		
		var bite = BITE_EFFECT.instantiate()
		get_tree().get_first_node_in_group("effects").add_child(bite)
		var bite_offset = get_sprite_content_center() + (attack_dir * attack_range)
		bite.global_position = bite_offset
		bite.rotation = attack_dir.angle()
		
		if target and get_distance_to_player() <= attack_range:
			target.take_damage(damage)
		
		# Two follow-up bites
		for i in range(2):
			await get_tree().create_timer(0.2).timeout
			
			if target and get_distance_to_player() <= attack_range:
				attack_dir = (target.global_position - global_position).normalized()
				sprite.flip_h = attack_dir.x < 0
				
				sprite.play("attack")
				await sprite.animation_finished
				
				bite = BITE_EFFECT.instantiate()
				get_tree().get_first_node_in_group("effects").add_child(bite)
				bite_offset = get_sprite_content_center() + (attack_dir * attack_range)
				bite.global_position = bite_offset
				
				if target and get_distance_to_player() <= attack_range:
					target.take_damage(damage)
	
	attack_timer.start()
