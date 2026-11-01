extends Resource
class_name InventoryItem

@export var display_name:String = "Name"
@export var icon:Texture2D
@export var item_scene:PackedScene
@export var ui_scene:PackedScene
@export var item_size:Vector2i = Vector2i(1, 1)
@export var item_weight:float = 1.0

var id:StringName
