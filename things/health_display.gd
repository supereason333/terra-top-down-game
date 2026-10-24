extends ProgressBar
class_name HealthDisplay

@export var health:HealthNode

func _ready() -> void:
	if !health:
		queue_free()
		return
	health.health_changed.connect(__health_changed)
	max_value = health.max_health
	value = health.health

func __health_changed(new:int):
	value = new
