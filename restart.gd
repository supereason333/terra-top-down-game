extends Button

func _ready() -> void:
	pressed.connect(restart)

func restart():
	get_tree().change_scene_to_file("res://world.tscn")
