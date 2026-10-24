extends ProgressBar
class_name HealthDisplay

@export var health:HealthNode

func _ready() -> void:
	if !health:
		queue_free()
		return
	health.health_changed.connect(__health_changed)
	max_value = health.max_health
	__health_changed(health.health)

func __health_changed(new:int):
	value = new
	_health_changed(new)

func _health_changed(_new:int):
	pass
