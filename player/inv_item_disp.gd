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
