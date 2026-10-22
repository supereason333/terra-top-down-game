extends Node2D
class_name World

@onready var projectiles:Node2D = $Projectiles

func register_projectile(proj:Projectile):
	projectiles.add_child(proj)
