extends Area2D

@onready var sprite = $AnimatedSprite2D
var speed: float = 400
var damage: int
var direction: Vector2 = Vector2.RIGHT

func _process(delta: float) -> void:
	position += direction * speed * delta

func launch(to_position: Vector2) -> void:
	direction = (to_position - global_position).normalized()
	rotation = direction.angle()
	
	start_lifetime_timer()

func set_damage(new_damage: int) -> void:
	damage = new_damage

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and body.is_in_group("player"):
		print("Damaging player")
		body.take_damage(damage)
	queue_free()
	
func start_lifetime_timer() -> void:
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(queue_free)
