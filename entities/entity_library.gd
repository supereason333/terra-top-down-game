extends Resource
class_name EntityLibrary

@export var lib:Dictionary[StringName, EntityResource]

func initilize() -> void:
	pass

func get_entity_node(id:StringName) -> Entity:
	var entity_resource:EntityResource = lib.get(id)
	if !entity_resource: return null
	var entity:Entity = entity_resource.entity_scene.instantiate()
	return entity
