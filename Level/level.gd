extends Node2D

@export var enemy_scene: PackedScene  # Сцена врага
@export var spawn_area: Rect2 = Rect2(Vector2(0, 0), Vector2(1920, 1080))   # Область спавна врагов
@export var spawn_rate: float = 2.0  # Частота появления врагов (секунды)
@export var max_enemies: int = 10  # Максимальное количество врагов

var current_enemies: int = 0  # Количество врагов на уровне

func _ready():
	# Убедимся, что сцена врага указана
	if enemy_scene == null:
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
	if current_enemies >= max_enemies:
		return

	var enemy = enemy_scene.instantiate() as Skeleton
	if enemy:
		enemy.name = "Skeleton" # Присвойте уникальное имя
		enemy.global_position = Vector2(
			randi_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x),
			randi_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
		)
		get_parent().add_child(enemy)
		current_enemies += 1
		enemy.connect("tree_exited", Callable(self, "_on_enemy_removed"))

func _on_enemy_removed():
	current_enemies -= 1
