extends CharacterBody2D
class_name Mimic

@export var animated_sprite: AnimatedSprite2D
@export var collision_shape: CollisionShape2D

var hostile: bool
var is_opened: bool = false

func _ready() -> void:
	randomize()
	var random_num = randf()
	if random_num <= 0.75:
		hostile = false
	else:
		hostile = true

func _process(_delta: float) -> void:
	if is_opened:
		pass

func create_loot() -> void:
	var loot_instance = ItemManager.instantiate_random_item()
	add_child(loot_instance)
	loot_instance.position.y -= 16

func open() -> void:
	if hostile:
		animated_sprite.play("mimic")
	else:
		animated_sprite.play("open")
	
	await animated_sprite.animation_finished
	
	is_opened = true
