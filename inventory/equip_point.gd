extends Marker2D
class_name EquipPoint

@export var source:Entity

var equipped:Item2D

func use():
	if equipped:
		equipped.use(source)
	_use(source)

func _use(_source:Entity):
	pass

func equip(new:Item2D) -> void:
	if equipped:
		remove_child(equipped)
	add_child(new)
	equipped = new

func unequip() -> void:
	if equipped:
		remove_child(equipped)
		equipped = null
