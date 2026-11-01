extends ColorRect
class_name InvItemDisp

@onready var texture_rect:TextureRect = $TextureRect

var item:Item2D

func _ready() -> void:
	if !item: return
	custom_minimum_size = Vector2(
		(item.size.x * (36 + 4)) - 4,
		(item.size.y * (36 + 4)) - 4
	)
	tooltip_text = item.id

	var item_res:InventoryItem = Global.item_library.lib.get(item.id)
	if item_res:
		if item_res.icon:
			texture_rect.texture = item_res.icon
