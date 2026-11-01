extends Item2D

func _use(source:Entity):
	source.health_node.heal(50)
	queue_free()
	gonna_be_freed.emit()
