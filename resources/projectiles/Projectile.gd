@icon("res://assets/icons/icon_projectile.png")
extends Area2D
class_name Projectile

@onready var sprite = $AnimatedSprite2D
var speed: float = 400
var damage: int
var direction: Vector2 = Vector2.RIGHT
signal despawning

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	position += direction * speed * delta

func launch(to_position: Vector2) -> void:
	direction = (to_position - global_position).normalized()
	rotation = direction.angle()
	
	start_lifetime_timer()

func set_damage(new_damage: int) -> void:
	damage = new_damage

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
	despawning.emit()
	queue_free()
	
func start_lifetime_timer() -> void:
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(signal_despawn)
	timer.timeout.connect(queue_free)

func signal_despawn() -> void:
	despawning.emit()
