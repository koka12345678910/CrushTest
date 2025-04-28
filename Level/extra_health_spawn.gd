extends Node2D

@export var health_scene: PackedScene  # Сцена врага
@export var spawn_area: Rect2 = Rect2(Vector2(0, 0), Vector2(1920, 1080))   # Область спавна врагов
@export var spawn_rate: float = 2.0  # Частота появления врагов (секунды)
@export var max_health: int = 10  # Максимальное количество врагов

var current_health: int = 0  # Количество врагов на уровне

func _ready():
	# Убедимся, что сцена врага указана
	if health_scene == null:
		print("Error: enemy_scene is not assigned!")
		return

	# Настраиваем таймер для спавна врагов
	var timer = Timer.new()
	timer.wait_time = spawn_rate
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_spawn_enemy"))

func _on_spawn_enemy():
	if current_health >= max_health:
		return

	var health_kit = health_scene.instantiate() as Extra_Health
	if health_kit:
		health_kit.name = "health" # Присвойте уникальное имя
		health_kit.global_position = Vector2(
			randi_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x),
			randi_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
		)
		get_parent().add_child(health_kit)
		current_health += 1
		health_kit.connect("tree_exited", Callable(self, "_on_enemy_removed"))

func _on_enemy_removed():
	current_health -= 1
