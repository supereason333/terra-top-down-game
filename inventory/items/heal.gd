extends Item2D

func _use(source:Entity):
	source.health_node.heal(10)
