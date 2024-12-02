extends Node2D

@export var background_music: AudioStream

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://scenes/enemy_selector.tscn")

func _ready() -> void:
	var enemy_path = get_tree().get_root().get_meta("selected_enemy_path")
	var enemy_count = get_tree().get_root().get_meta("enemy_count")
	var enemy_variants = get_tree().get_root().get_meta("enemy_variants")
	
	if enemy_path:
		for i in enemy_count:
			var enemy = instantiate_enemy(enemy_path)
			if i < enemy_variants.size():
				var variant = enemy_variants[i]
				enemy.modification_color = variant.color
				
		get_tree().get_root().remove_meta("selected_enemy_path")
		get_tree().get_root().remove_meta("enemy_count")
		get_tree().get_root().remove_meta("enemy_variants")
	
	var projectiles = Node2D.new()
	add_child(projectiles)
	projectiles.add_to_group("projectiles")
	
	SoundManager.play_music(background_music)

func instantiate_enemy(enemy_path: String) -> Node:
	var enemy_instance = EnemyManager.instantiate_enemy_by_path(enemy_path)
	add_child(enemy_instance)
	enemy_instance.position += Vector2(randi_range(-32, 32), randi_range(-32, 32))
	return enemy_instance

func apply_variant_effects(enemy: Node, variant: EnemyVariant) -> void:
	match variant.name:
		"Enraged":
			enemy.damage *= 1.5
			enemy.speed *= 1.2
		"Tough":
			enemy.health *= 2
			enemy.speed *= 0.8
		"Toxic":
			# Add poison trail functionality
			pass
		"Swift":
			enemy.speed *= 1.5
			enemy.attack_timer.wait_time *= 0.8

func _exit_tree() -> void:
	SoundManager.stop(background_music)
