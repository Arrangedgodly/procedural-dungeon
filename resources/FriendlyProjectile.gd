extends Projectile
class_name FriendlyProjectile

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage") and body.is_in_group("enemies"):
		body.take_damage(damage)
		despawning.emit()
		queue_free()
