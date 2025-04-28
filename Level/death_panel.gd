extends Control

@onready var best_time_label = $Panel/Label
@onready var current_time_label = $Panel/Label2
@onready var best_kills_label = $Panel/Label3
@onready var current_kills_label = $Panel/Label4

func _ready() -> void:
	pass

# Устанавливаем время для отображения
func set_best_time(best_time: float, current_time: float, best_kills: int, current_kills: int):
	if best_time_label and current_time_label:
		best_time_label.text = "Best: 
			Time = %.2f s" % best_time
		current_time_label.text = "Current: 
			Time = %.2f s" % current_time

	if best_kills_label and current_kills_label:
		best_kills_label.text = "Kills: %d" % best_kills
		current_kills_label.text = "Kills: %d" % current_kills

func _on_again_pressed() -> void:
	# Удаляем всех врагов
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	GameStats.reset_kills()
	get_tree().reload_current_scene()
	hide()

func _on_quit_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Level/menu.tscn")
