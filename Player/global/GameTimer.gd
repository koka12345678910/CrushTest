extends Node


class_name Game_Timer

var best_time: float = 0.0  # Переменная для хранения лучшего времени
const SAVE_FILE_PATH: String = "user://save_data.json"

func _ready() -> void:
	best_time = load_data()
	print("Лучшее время загружено:", best_time)

func save_data(best_time: float):
	var data = {"best_time": best_time}
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func load_data() -> float:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		var file_content = file.get_as_text()
		file.close()
		
		# Парсим JSON
		var parse_result = JSON.parse_string(file_content)
		
		# Проверяем, успешен ли парсинг
		if parse_result and parse_result.has("best_time"):
			return float(parse_result["best_time"])
		else:
			print("Ошибка: Невозможно загрузить лучшее время из JSON")
	else:
		print("Файл с сохранением не найден")
	return 0.0

# Обновление лучшего времени
func update_best_time(current_time: float):
	if current_time > best_time:
		best_time = current_time
		save_data(best_time)  # Сразу сохраняем изменения

# Получить лучшее время
func get_best_time() -> float:
	return best_time
