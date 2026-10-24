extends Marker2D
class_name EquipPoint

var equipped:Item2D

func use():
	if equipped:
		equipped.use()
	_use()

func _use():
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
