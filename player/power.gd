extends Node
class_name PowerMngr

## for notifying if power is out and thing needs to turn off
signal load_removed(id:int)

@export var max_storage:float = 40
@export var base_regen:float = 3	# E/s
@export var reserve:float = 10

var energy:float = 0
var net_regen:float = 0

var loads:Dictionary[int, float]
var sources:Dictionary[int, float]

func get_energy(amount:float, from_reserve:bool = false) -> bool:
	if from_reserve:
		if energy < amount: return false
		energy -= amount
		return true
	else:
		if energy - reserve < amount: return false
		energy -= amount
		return true

func add_load(rate:float) -> int:
	var id := randi()
	loads[id] = rate
	return id

func remove_load(id:int) -> bool:
	return loads.erase(id)

func _process(delta: float) -> void:
	var total_regen := base_regen + sum(sources)
	energy += total_regen * delta
	net_regen = total_regen

	for id in loads.keys():
		if energy < loads[id]:
			load_removed.emit(id)
			loads.erase(id)
		energy -= loads[id] * delta
		net_regen -= loads[id] * delta

	energy = clamp(energy, 0, max_storage)

func sum(dict:Dictionary[int, float]) -> float:
	var s := 0.0
	for value in dict.values():
		s += value
	return s
