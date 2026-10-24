extends Node2D
class_name Projectile

@export var area:Area2D
@export var lifetime := 60.0
@export var base_damage := 10
@export var penetration := 1

var hits:int = 0
var dead:bool = false

func _ready() -> void:
	if area:
		area.body_entered.connect(_on_body_entered)

	_proj_init()

	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _proj_init() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		kill()
	elif body is Entity:
		_on_hit(body)
	elif body is CollisionObject2D:
		if body.collision_layer & 1 > 0:
			kill()
		# elif body.collision_layer >> 2 & 1 > 0:
		# 	if body is Entity:


func _on_hit(entity:Entity):
	if !entity.health_node:
		hits += 1
		if hits >= penetration:
			kill()
		return
	entity.health_node.damage(base_damage)
	hits += 1
	if hits >= penetration:
		kill()

func kill():
	dead = true

	_kill()

# override for death logic
func _kill():
	queue_free()
