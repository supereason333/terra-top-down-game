extends VBoxContainer

@onready var inventory:Inventory = %Inventory

func _ready() -> void:
	for item in ItemMngr.lib.keys():
		var btn := Button.new()
		btn.text = item
		btn.pressed.connect(give.bind(item))
		add_child(btn)

func give(id:StringName):
	var item:Item2D = ItemMngr.get_item_node(id)
	inventory.add_item(item)
