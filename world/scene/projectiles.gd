extends Node2D
class_name ProjectileMngr

var projectiles := 0

func register_projectile(id:StringName, new_transform:Transform2D):
	var proj:Projectile = Global.projectile_library.get_projectile_node(id)
	if !proj: return

	proj.transform = new_transform

	get_tree().create_timer(proj.lifetime).timeout.connect(proj.queue_free)
	proj.tree_exited.connect(_proj_exit_tree)
	projectiles += 1

	add_child(proj)

func _proj_exit_tree() -> void:
	projectiles -= 1
