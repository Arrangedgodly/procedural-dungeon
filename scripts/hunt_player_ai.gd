extends BeehaveTree

@onready var attack_sequence: SequenceComposite = $SelectorComposite/AttackSequence
@onready var approach_player_sequence: SequenceComposite = $SelectorComposite/ApproachPlayerSequence

@export var attack_action: Script
@export var movement_action: Script

func set_action(action: Script, sequence: SequenceComposite) -> void:
	for child in sequence.get_children():
		if child is ActionLeaf:
			child.queue_free()
	
	if action:
		var action_leaf = action.new()
		sequence.add_child(action_leaf)

func _ready() -> void:
	set_action(attack_action, attack_sequence)
	set_action(movement_action, approach_player_sequence)
