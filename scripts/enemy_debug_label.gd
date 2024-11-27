extends Control
@onready var state: Label = $VBoxContainer/State/State
@onready var health: Label = $VBoxContainer/Health/Health
@onready var distance: Label = $VBoxContainer/Distance/Distance
@onready var speed: Label = $VBoxContainer/Speed/Speed
@onready var damage: Label = $VBoxContainer/Damage/Damage
@onready var attack: Label = $"VBoxContainer/Attack Range/Attack"
@onready var approach: Label = $"VBoxContainer/Approach Range/Approach"

func _ready() -> void:
	add_to_group("debug")
	hide()

func init(new_state: String, new_health: int, new_distance: float, new_speed: int, new_damage: int, new_attack: int, new_approach: int) -> void:
	state.text = new_state
	health.text = str(new_health)
	distance.text = str(snapped(new_distance, .01))
	speed.text = str(new_speed)
	damage.text = str(new_damage)
	attack.text = str(new_attack)
	approach.text = str(new_approach)

func update_state(new_value: String) -> void:
	state.text = new_value

func update_health(new_value: int) -> void:
	health.text = str(new_value)

func update_distance(new_value: float) -> void:
	distance.text = str(snapped(new_value, .01))
