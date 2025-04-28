extends Control
class_name Pause

var player: Player = null

func _ready() -> void:
	hide()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		show()
		set_physics_process(false)


func _on_button_pressed() -> void:
	!get_tree().paused
	hide()


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Level/menu.tscn")
