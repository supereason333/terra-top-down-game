extends ColorRect
class_name PlayerSlot

signal item_changed(new:Item2D)

## empty means anything
@export var filter_tags: Array[StringName]
@export var default_texture:Texture2D

@onready var name_label: Label = $NameLabel
@onready var icon_rect:TextureRect = $IconRect

var item: Item2D

func _ready() -> void:
	item_changed.connect(_item_changed)
	_item_changed(item)

func _item_changed(itm: Item2D) -> void:
	if !itm:
		if default_texture:
			icon_rect.texture = default_texture
			name_label.hide()
			icon_rect.show()
		else:
			name_label.text = name
			name_label.modulate = Color.DARK_SALMON
			name_label.show()
			icon_rect.hide()
		return

	var tex:Texture2D
	var itm_res:InventoryItem = Global.item_library.lib.get(itm.id)
	if itm_res:
		if itm_res.icon_32:
			tex = itm_res.icon_32
		elif itm_res.icon:
			tex = itm_res.icon

	if tex:
		name_label.hide()
		icon_rect.show()
		icon_rect.texture = tex
	else:
		name_label.show()
		icon_rect.hide()
		name_label.text = itm.id
		name_label.modulate = Color.WHITE

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not item:
		return null
	var data := InvDragData.new(item)
	data.drop_successful.connect(_drop_successful)

	var label := Label.new()
	label.text = item.id
	set_drag_preview(label)
	return data

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if item or data is not InvDragData:
		return false
	return accepts((data as InvDragData).item)

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var d := data as InvDragData
	if d and set_item(d.item):
		d.drop_successful.emit()

# does filtering and stuff
func accepts(itm: Item2D) -> bool:
	if itm == null or filter_tags.is_empty():
		return true
	for tag in filter_tags:
		if itm.tags.has(tag):
			return true
	return false

# doesnt work if the slot already has an item
func set_item(itm: Item2D) -> bool:
	if item or itm == null or not accepts(itm):
		return false
	_watch(itm)
	item = itm
	item_changed.emit(item)
	return true

func remove_item() -> Item2D:
	if not item:
		return null
	var old := item
	_unwatch(old)
	item = null
	item_changed.emit(null)
	return old

# swaps with another slot
func swap_item(slot: PlayerSlot) -> Item2D:
	if slot == null or slot == self:
		return null
	if not accepts(slot.item) or not slot.accepts(item):
		return null
	if get_viewport().gui_is_dragging(): return null

	var mine := item
	var theirs := slot.item
	if mine:
		_unwatch(mine)
	if theirs:
		slot._unwatch(theirs)

	item = theirs
	slot.item = mine

	if theirs:
		_watch(theirs)
	if mine:
		slot._watch(mine)

	item_changed.emit(item)
	slot.item_changed.emit(slot.item)
	return theirs

func _watch(itm: Item2D) -> void:
	if not itm.gonna_be_freed.is_connected(_item_gonna_be_freed):
		itm.gonna_be_freed.connect(_item_gonna_be_freed)

func _unwatch(itm: Item2D) -> void:
	if itm.gonna_be_freed.is_connected(_item_gonna_be_freed):
		itm.gonna_be_freed.disconnect(_item_gonna_be_freed)

func _drop_successful() -> void:
	remove_item()

func _item_gonna_be_freed() -> void:
	remove_item()
