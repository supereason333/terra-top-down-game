extends ProgressBar

@onready var power:PowerMngr = %Power
@onready var energy_label:Label = $"Labels/EnergyLabel"
@onready var regen_label:Label = $"Labels/NetRegenLabel"

func _ready() -> void:
	max_value = power.max_storage

func _process(_delta: float) -> void:
	energy_label.text = "%d/%d E" % [power.energy, power.max_storage]
	if power.net_regen > 0:
		regen_label.text = "+%d E/s" % power.net_regen
	else:
		regen_label.text = "%d E/s" % power.net_regen

	value = power.energy
