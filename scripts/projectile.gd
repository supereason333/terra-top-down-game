extends Node2D
class_name Projectile

@export var lifetime := 60.0
@export var base_damage := 10
@export var penetration := 1

func _ready() -> void:
	_proj_init()

	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _proj_init() -> void:
	pass
