extends CharacterBody2D
class_name Entity

@export var ai:EntityAI

func _ready() -> void:
	if !ai:
		print_debug("Entity has no set AI, finding child")
		for child in get_children():
			if child is EntityAI:
				ai = child
