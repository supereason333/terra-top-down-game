extends Camera2D

const SPEED = 200

func _process(delta: float) -> void:
	position += Input.get_vector("left", "right", "up", "down") * delta * 200
