extends ColorRect

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		visible = !visible
