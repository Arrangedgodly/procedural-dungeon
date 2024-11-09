extends Resource
class_name DungeonSize

signal value_changed(property: String, value: Variant)

# Dictionary to store property constraints
const PROPERTY_CONSTRAINTS = {
	"rooms_generated": {"min": 5, "max": 10000, "default": 100},
	"min_size": {"min": 5, "max": 20, "default": 10},
	"max_size": {"min": 10, "max": 50, "default": 30},
	"horizontal_spread": {"min": 100, "max": 1000, "default": 300},
	"corridor_width": {"min": 1, "max": 7, "default": 3}
}

@export var cull_amount = 0.5

# Dictionary to store the actual values
var _values: Dictionary = {}

func _init() -> void:
	# Initialize all properties with default values
	for property in PROPERTY_CONSTRAINTS:
		_values[property] = PROPERTY_CONSTRAINTS[property]["default"]

# Generic getter
func get_value(property: String) -> Variant:
	if _values.has(property):
		return _values[property]
	push_error("Property '%s' not found in DungeonSize" % property)
	return null

# Generic setter with validation
func set_value(property: String, value: Variant) -> bool:
	if not PROPERTY_CONSTRAINTS.has(property):
		push_error("Property '%s' not found in DungeonSize" % property)
		return false
		
	var constraints = PROPERTY_CONSTRAINTS[property]
	
	# Validate against constraints
	if value < constraints.min:
		value = constraints.min
	elif value > constraints.max:
		value = constraints.max
	
	# Only update if value actually changed
	if _values.get(property) != value:
		_values[property] = value
		value_changed.emit(property, value)
	
	return true

# Property getters and setters using the generic functions
var rooms_generated: int:
	get: return get_value("rooms_generated")
	set(value): set_value("rooms_generated", value)

var min_size: int:
	get: return get_value("min_size")
	set(value): set_value("min_size", value)

var max_size: int:
	get: return get_value("max_size")
	set(value): set_value("max_size", value)

var horizontal_spread: int:
	get: return get_value("horizontal_spread")
	set(value): set_value("horizontal_spread", value)

var corridor_width: int:
	get: return get_value("corridor_width")
	set(value): set_value("corridor_width", value)

# Utility functions
func to_dictionary() -> Dictionary:
	return _values.duplicate()

func from_dictionary(data: Dictionary) -> void:
	for key in data:
		set_value(key, data[key])

# Validation functions
func validate_size_relationship() -> bool:
	return min_size < max_size

func is_valid() -> bool:
	return validate_size_relationship()
