extends Area2D
class_name InteractArea

signal interacted(player:Player)
signal player_entered(player:Player)
signal player_exited()

func interact(player:Player):
	if !player: return
	interacted.emit(player)

func player_enter(player:Player):
	if !player: return
	player_entered.emit(player)

func player_exit():
	player_exited.emit()
