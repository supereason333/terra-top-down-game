extends Node2D
class_name Item2D

var id:StringName

# Unique items cannot stack
var unique:bool = false
var stackable:bool = true

var amount:int = 1

func use(source:Entity):
	_use(source)

func _use(_source:Entity):
	pass
