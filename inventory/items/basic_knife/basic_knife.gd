extends Item2D

@onready var cooldown_timer:Timer = $CooldownTimer
@onready var attack_area:Area2D = $Area2D


func _use(source:Entity):
	if cooldown_timer.is_stopped():
		cooldown_timer.start()

		used_successfully.emit()

		for body in attack_area.get_overlapping_bodies():
			if body == source: continue
			if body is Entity:
				if body.health_node:
					body.health_node.damage(10)
