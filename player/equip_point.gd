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

func equip(new:Item2D) -> void:
	super(new)
	if current_ui: current_ui.queue_free()

	var item_data:InventoryItem = ItemMngr.lib.get(new.id)
	if item_data.ui_scene:
		var ui:ItemUI = item_data.ui_scene.instantiate()
		ui.item = new
		current_ui = ui
		ui_root.add_child(ui)

func unequip() -> void:
	super()
	if current_ui: current_ui.queue_free()
