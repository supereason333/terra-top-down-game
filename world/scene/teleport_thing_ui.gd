extends Control

@onready var canvas:CanvasLayer = $".."

func _ready() -> void:
	_on_canvas_layer_visibility_changed()

func _shortcut_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		canvas.hide()
	get_viewport().set_input_as_handled()

func _on_canvas_layer_visibility_changed() -> void:
	if canvas.visible:
		set_process_shortcut_input(true)
		GameMngr.get_player().hide_ui_canvas()
	else:
		set_process_shortcut_input(false)
		GameMngr.get_player().show_ui_canvas()
