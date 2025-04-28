extends Node

class_name Game_Stats

var kill_count: int = 0  # Количество убийств
var best_kill_count: int = 0  # Лучший результат убийств

func _ready() -> void:
	load_data()

func reset_kills():
	kill_count = 0

func increment_kills():
	kill_count += 1

func save_best_kill_count():
	if kill_count > best_kill_count:
		best_kill_count = kill_count
		save_data()

func save_data():
	var save_data = {
		"best_kill_count": best_kill_count
	}
	var save_file = FileAccess.open("user://game_stats.save", FileAccess.WRITE)
	save_file.store_string(JSON.stringify(save_data))  # Используем JSON.stringify()
	save_file.close()

func load_data():
	if FileAccess.file_exists("user://game_stats.save"):
		var save_file = FileAccess.open("user://game_stats.save", FileAccess.READ)
		var json_text = save_file.get_as_text()
		save_file.close()

		var parsed_json = JSON.parse_string(json_text)  # Парсим JSON
		if parsed_json is Dictionary:  # Проверяем, что получен словарь
			best_kill_count = parsed_json.get("best_kill_count", 0)
