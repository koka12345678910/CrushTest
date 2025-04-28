extends Node2D

@onready var anim = $AnimationPlayer

func _ready() -> void:
	anim.play("light")

func _process(_delta: float) -> void:
	pass

func _on_play_pressed() -> void:
	anim.stop()
	anim.play("blackout")
	await get_tree().create_timer(anim.current_animation_length).timeout
	get_tree().change_scene_to_file("res://Level/level.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
