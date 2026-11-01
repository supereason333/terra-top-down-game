extends Node2D
class_name Item2D

# signal to signal when consumable is used it leaves tree yeah yk
# somethign something something exiting tree didnt work something somethign something
signal gonna_be_freed
signal used

var id:StringName

var weight := 1.0
var size:Vector2i = Vector2i(1, 1)
var tags:Dictionary[StringName, ItemTagInfo]

func use(source:Entity):
	_use(source)
	used.emit()

func _use(_source:Entity):
	pass
