extends Projectile
class_name LinearProjectile

@export var speed := 100

var vec:Vector2

func _proj_init() -> void:
	vec = Vector2(1, 0).rotated(rotation)


func _physics_process(delta: float) -> void:
	position += vec * speed * delta
