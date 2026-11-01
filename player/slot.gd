extends ColorRect
class_name PlayerSlot

signal item_changed(new:Item2D)

@onready var name_label:Label = $NameLabel

var item:Item2D

func _ready() -> void:
	item_changed.connect(_item_changed)
	name_label.text = name

func _item_changed(itm:Item2D):
	if itm: name_label.text = item.id
	else: name_label.text = name

func _get_drag_data(_at_position: Vector2) -> Variant:
	if !item: return null
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

func set_item(itm:Item2D) -> bool:
	if item: return false
	item = itm
	item_changed.emit()
	return true

func remove_item() -> Item2D:
	if !item: return null
	var i = item
	item = null
	item_changed.emit(null)
	return i

# Sets then returns the old one
func swap_item(slot:PlayerSlot) -> Item2D:
	if !slot: return
	var itm = slot.item
	slot.item = item
	item = itm
	item_changed.emit(item)
	slot.item_changed.emit(slot.item)
	return itm

func _drop_successful():
	item = null
	item_changed.emit(null)
