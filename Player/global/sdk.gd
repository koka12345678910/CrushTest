extends Node

@onready var js_bridge = JavaScriptBridge

# Функция для показа рекламы
func show_ad():
	print("Показываем рекламу...")
	if js_bridge:
		js_bridge.eval("showAd()", false)
	else:
		print("Ошибка: JavaScriptBridge не найден!")

# Callback, если реклама открылась
func on_ad_opened():
	print("Реклама началась. Останавливаем игру.")
	get_tree().paused = true  # Ставим игру на паузу

# Callback, если реклама закрылась
func on_ad_closed(successful):
	print("Реклама завершена. Возвращаем игру в нормальное состояние.")
	get_tree().paused = false  # Снимаем паузу
	get_tree().reload_current_scene()  # Перезапускаем уровень после рекламы

# Callback, если реклама не загрузилась
func on_ad_failed():
	print("Ошибка рекламы. Просто перезапускаем уровень.")
	get_tree().reload_current_scene()
