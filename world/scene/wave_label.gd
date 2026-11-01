extends Label

func _ready() -> void:
	text = "You made it to level %d!!!!!" % GameMngr.level
