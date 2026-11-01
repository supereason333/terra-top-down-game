extends Node2D
class_name EntityMngr

var entities := 0

func register_entity_from_id(id:StringName, new_position:Vector2):
	var entity:Entity = Global.entity_library.get_entity_node(id)
	if !entity: return

	entity.position = new_position

	register_entity(entity)

func register_entity(entity:Entity):
	entity.tree_exited.connect(_proj_exit_tree)
	entities += 1

	add_child(entity)

func _proj_exit_tree() -> void:
	entities -= 1

func clear_entities():
	for child in get_children():
		child.queue_free()
