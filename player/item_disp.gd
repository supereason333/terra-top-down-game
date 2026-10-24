extends HBoxContainer
class_name InvItemDisp

@onready var btn:CheckBox = $EquipCheck
@onready var label:Label = $Label

var slot:int
var item:Item2D
var selected:bool = false:
	set(value):
		if value == selected: return
		selected = value
		if is_node_ready():
			btn.button_pressed = selected

func _ready() -> void:
	btn.button_pressed = selected
	if item:
		label.text = item.id
