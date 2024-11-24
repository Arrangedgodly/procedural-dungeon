extends CanvasLayer

signal config_confirmed(enemy_path: String, count: int, variants: Array)

@onready var count_spinbox: SpinBox = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/CountSpinBox
@onready var variant_option: OptionButton = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/VariantOption
@onready var randomize_check: CheckBox = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/RandomizeCheck
@onready var confirm_button: Button = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/ConfirmButton
@onready var cancel_button: Button = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/CancelButton
@onready var description_label: Label = $PanelContainer/MarginContainer/VBoxContainer/DescriptionLabel

var enemy_path: String
var variants: Array[EnemyVariant] = [
	create_variant("Normal", Color.WHITE, "Standard enemy behavior"),
	create_variant("Enraged", Color.RED, "Increased damage and speed"),
	create_variant("Tough", Color.BLUE, "Higher health, slower speed"),
	create_variant("Toxic", Color.GREEN, "Leaves poison trails"),
	create_variant("Swift", Color.YELLOW, "Faster movement and attack speed"),
	# Add more variants as needed
]

func create_variant(variant_name: String, color: Color, description: String) -> EnemyVariant:
	var variant = EnemyVariant.new()
	variant.name = variant_name
	variant.color = color
	variant.description = description
	return variant

func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm)
	cancel_button.pressed.connect(_on_cancel)
	variant_option.item_selected.connect(_on_variant_selected)
	
	# Populate variant options
	for variant in variants:
		variant_option.add_item(variant.name)
	
func setup(path: String) -> void:
	enemy_path = path
	count_spinbox.value = 1
	count_spinbox.max_value = 10
	randomize_check.button_pressed = false
	_on_variant_selected(0)  # Show first variant's description
	
func _on_variant_selected(index: int) -> void:
	if index == 0:
		description_label.text = ""
	else:
		description_label.text = variants[index - 1].description
	
func _on_confirm() -> void:
	var selected_variants = []
	
	if randomize_check.button_pressed:
		# Randomly select variants for each enemy
		for i in count_spinbox.value:
			selected_variants.append(variants.pick_random())
	else:
		# Use same variant for all enemies
		var selected_variant = variants[variant_option.selected]
		for i in count_spinbox.value:
			selected_variants.append(selected_variant)
	
	config_confirmed.emit(enemy_path, count_spinbox.value, selected_variants)
	queue_free()
	
func _on_cancel() -> void:
	queue_free()
