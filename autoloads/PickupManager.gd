extends Node

const COLLECTION_DELAY = 0.1

signal collection_complete

static var instance: Node

func _ready() -> void:
	instance = self

static func get_instance() -> Node:
	return instance

func collect_all_pickups(player: Node2D) -> void:
	var pickups = get_tree().get_nodes_in_group("pickups")
	if pickups.is_empty():
		collection_complete.emit()
		return
	
	var health_packs = []
	var other_pickups = []
	
	for pickup in pickups:
		if pickup is HealthPack:
			if pickup.should_auto_collect(player):
				health_packs.append(pickup)
		else:
			other_pickups.append(pickup)
	
	health_packs.sort_custom(func(a, b):
		var dist_a = player.global_position.distance_squared_to(a.global_position)
		var dist_b = player.global_position.distance_squared_to(b.global_position)
		return dist_a < dist_b
	)
	
	collect_pickups_sequence.call_deferred(health_packs, player)
	collect_pickups_sequence.call_deferred(other_pickups, player)

func collect_pickups_sequence(pickups: Array, player: Node2D) -> void:
	for pickup in pickups:
		if is_instance_valid(pickup):
			pickup.start_collection(player)
			await get_tree().create_timer(COLLECTION_DELAY).timeout
