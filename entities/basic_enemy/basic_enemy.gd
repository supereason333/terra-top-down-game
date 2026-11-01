extends Entity

func _kill():
	do_drops()

	queue_free()

func do_drops():
	var world := GameMngr.get_world()
	if !world: return
	var items := world.get_items()
	if !items: return

	var r := randf()
	if r < 0.2:
		items.add_drop_from_id(&"power_cell", global_position)
	elif r < 0.4:
		items.add_drop_from_id(&"heal", global_position)
