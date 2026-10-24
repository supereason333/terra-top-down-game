extends Item2D

@onready var cooldown_timer:Timer = $CooldownTimer
@onready var attack_area:Area2D = $Area2D
@onready var attack_disp:MeshInstance2D = $AttackDisp


func _use():
	if cooldown_timer.is_stopped():
		cooldown_timer.start()

		attack_disp.show()
		get_tree().create_timer(0.1).timeout.connect(attack_disp.hide)

		for body in attack_area.get_overlapping_bodies():
			if body is Player:
				body.health_node.damage(10)
