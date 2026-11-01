extends EquipPoint
class_name PlayerEquipPoint

@export var ui_root:Control

var current_ui:ItemUI

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			use()

func register_ui():
	pass
