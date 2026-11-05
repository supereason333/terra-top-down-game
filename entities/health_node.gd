extends Node
class_name HealthNode

signal health_changed(new:int)
signal damaged(dmg:int)
signal healed(health:int)
signal death

@export var max_health := 100

var health := 100

func damage(dmg:int):
	if health <= 0: return
	health -= dmg
	health = clamp(health, 0, max_health)
	damaged.emit(dmg)
	health_changed.emit(health)
	if health <= 0:
		death.emit()

func heal(value:int):
	health += value
	health = clamp(health, 0, max_health)
	healed.emit(value)
	health_changed.emit(health)
