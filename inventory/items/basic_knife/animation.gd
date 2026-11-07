extends Node

@onready var knife_pivot:Node2D = %KnifePivot
@onready var knife:MeshInstance2D = %Knife

var position:int = 0
var tween:Tween

var positions = [	# pivot first then knife rotation
	0.0,
	-134.3
]

func _on_knife_used() -> void:
	if tween:
		tween.kill()
	tween = create_tween()

	position = wrapi(position + 1, 0, 2)

	tween.tween_property(knife_pivot, "rotation_degrees", positions[position], 0.1)
