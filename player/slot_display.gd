extends ColorRect

@onready var icon_rect:TextureRect = $IconRect

@export var target_slot:PlayerSlot

func _ready() -> void:
	if !target_slot: return
	target_slot.item_changed.connect(_update_display)

func _update_display(item:Item2D) -> void:
	if !item:
		icon_rect.texture = null
		return
	var itm:InventoryItem = Global.item_library.lib.get(item.id)
	if !itm:
		icon_rect.texture = null
		return
	if itm.icon_32:
		icon_rect.texture = itm.icon_32
	else:
		icon_rect.texture = itm.icon
