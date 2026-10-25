extends ItemUI

@onready var ammo_label:Label = $AmmoLabel

func _ready() -> void:
	if !item: return
	if item.get(&"ammo") == null or item.get(&"mag_size") == null:
		ammo_label.text = "_/_"
		item = null
		return

	if item:
		item.used.connect(update)
	update()

func update():
	if item and is_node_ready():
		ammo_label.text = "%d/%d" % [item.ammo, item.mag_size]
