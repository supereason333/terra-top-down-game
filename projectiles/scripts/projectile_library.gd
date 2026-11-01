extends Resource
class_name ProjectileLibrary

@export var lib:Dictionary[StringName, ProjectileResource]

func initilize():
	pass

func get_projectile_node(id:StringName) -> Projectile:
	var res:ProjectileResource = lib.get(id)
	if !res: return null
	return res.projectile_scene.instantiate()
