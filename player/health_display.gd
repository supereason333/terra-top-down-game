extends HealthDisplay

func _health_changed(new:int):
	$Label.text = "HP: %d" % new
