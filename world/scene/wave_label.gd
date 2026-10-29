extends Label

func _ready() -> void:
	text = "You made it to wave %d!!!!!" % GameMngr.wave
