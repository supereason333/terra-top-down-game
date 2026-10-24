extends Resource
class_name InventoryItem

@export var display_name:String = "Name"
@export var icon:Texture2D
@export var item_scene:PackedScene
@export var stackable:bool = false

var id:StringName
