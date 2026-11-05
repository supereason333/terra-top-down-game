extends Item2D

@onready var light:PointLight2D = $Light

@export var power_drain := 1.0

var load_id := -1
var pwr:PowerMngr

func _use(source:Entity):
	if light.enabled:
		light.enabled = false
		if load_id == -1: return
		if source is Player:
			if !pwr: pwr = source.get_power()
			pwr.remove_load(load_id)
			if pwr.load_removed.is_connected(_power_out):
				pwr.load_removed.disconnect(_power_out)
	else:
		light.enabled = true

		if source is Player:
			if !pwr: pwr = source.get_power()
			load_id = pwr.add_load(power_drain)

			if !pwr.load_removed.is_connected(_power_out):
				pwr.load_removed.connect(_power_out)

func _power_out(i:int):
	if i != load_id: return
	load_id = -1
	light.enabled = false
	if !pwr: return
	if pwr.load_removed.is_connected(_power_out):
		pwr.load_removed.disconnect(_power_out)

func _on_tree_exiting() -> void:
	light.enabled = false
	if load_id == -1: return
	if !pwr: return
	pwr.remove_load(load_id)
	load_id = -1
