extends Node2D

@onready var ui_canvas:CanvasLayer = $CanvasLayer

func _on_interacted(_player: Player) -> void:
	ui_canvas.show()
	# player.hide_ui_canvas()

func _on_player_exited() -> void:
	ui_canvas.hide()
