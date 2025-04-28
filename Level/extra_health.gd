extends Control
class_name Extra_Health

var player: Player = null

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.health = min(body.health + 25, 100)  # Ограничиваем HP до 200
		body.update_health_bar()  # Обновляем интерфейс HP
		queue_free()
