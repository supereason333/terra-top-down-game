extends Marker2D
class_name EquipPoint

@export var source:Entity
@export var inventory:Inventory
@export var equipped_slot:int = 0

var equipped:Item2D

func _ready() -> void:
	if !inventory: return
	inventory.items_changed.connect(_on_items_changed)
	_on_items_changed()

func _on_items_changed() -> void:
	if inventory.inv[equipped_slot] == equipped: return
	if equipped:
		var p = equipped.get_parent()
		if p:
			p.remove_child(equipped)
	equipped = inventory.inv[equipped_slot]
	add_child(equipped)

func use():
	if equipped:
		equipped.use(source)
	_use(source)

func _use(_source:Entity):
	pass
