extends CanvasLayer

@onready var health_bar: TextureProgressBar = $HBoxContainer/HealthBar
@onready var mana_bar: TextureProgressBar = $HBoxContainer/ManaBar
@onready var stamina_bar: TextureProgressBar = $HBoxContainer/StaminaBar
@export var player: Player

func _ready() -> void:
	player.health_changed.connect(set_health_value)
	player.stamina_changed.connect(set_stamina_value)
	health_bar.init(player.health)
	mana_bar.init(player.mana)
	stamina_bar.init(player.stamina)
	
func set_health_value(new_health: int) -> void:
	health_bar.set_progress_value(new_health)

func set_mana_value(new_mana: int) -> void:
	mana_bar.set_progress_value(new_mana)
	
func set_stamina_value(new_stamina: int) -> void:
	stamina_bar.set_progress_value(new_stamina)
