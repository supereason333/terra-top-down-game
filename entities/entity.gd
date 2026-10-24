extends RigidBody2D
class_name Entity

signal entity_death

@export var health_node:HealthNode

var dead:bool = false

func _ready() -> void:
	if !health_node:
		for child in get_children():
			if child is HealthNode:
				health_node = child
	if health_node:
		health_node.death.connect(kill)

# mandetory logic for entity
func kill():
	dead = true
	entity_death.emit()
	_kill()

# override this to do death logic
func _kill():
	queue_free()
