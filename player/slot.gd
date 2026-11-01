extends ColorRect
class_name PlayerSlot

signal item_changed(new:Item2D)

@onready var name_label:Label = $NameLabel

var item:Item2D

func _ready() -> void:
	item_changed.connect(_item_changed)
	name_label.text = name

func _item_changed(item:Item2D):
	if item: name_label.text = item.id
	else: name_label.text = name

func _get_drag_data(_at_position: Vector2) -> Variant:
	if !item: return false
	var data := InvDragData.new(item)
	data.drop_successful.connect(_drop_successful)

	var label := Label.new()
	label.text = item.id
	set_drag_preview(label)

	return data

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if item: return false
	if data is not InvDragData: return false
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if item: return
	if data is InvDragData:
		item = data.item
		data.drop_successful.emit()
		item_changed.emit(item)

func _drop_successful():
	item = null
	item_changed.emit(null)
