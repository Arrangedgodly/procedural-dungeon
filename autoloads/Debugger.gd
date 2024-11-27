extends Node

var debug_shown: bool = false

func show() -> void:
	debug_shown = true
	for child in get_tree().get_nodes_in_group("debug"):
		child.show()
	
func hide() -> void:
	debug_shown = false
	for child in get_tree().get_nodes_in_group("debug"):
		child.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		if debug_shown:
			hide()
		else:
			show()
