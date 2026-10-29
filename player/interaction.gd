extends Area2D

@onready var player:Player = $".."

var avalible:Array[InteractArea]

func _on_area_exited(area: Area2D) -> void:
	if area is InteractArea:
		area.player_exit()
		avalible.erase(area)

func _on_area_entered(area: Area2D) -> void:
	if area is InteractArea:
		area.player_enter(player)
		avalible.append(area)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if !avalible.is_empty():
			avalible[-1].interact(player)
