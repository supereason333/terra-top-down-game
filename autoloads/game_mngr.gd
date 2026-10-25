extends Node

func get_world() -> World:
	for child in get_parent().get_children():
		if child is World: return child
	return null

func get_player() -> Player:
	var nodes = get_tree().get_nodes_in_group(&"player")
	for node in nodes:
		if node is Player:
			return node
	return null

func get_player_inv() -> Inventory:
	var player:Player = get_player()
	if !player: return null
	return player.get_inventory()

func get_player_health() -> HealthNode:
	var player:Player = get_player()
	if !player: return null
	return player.get_health()
