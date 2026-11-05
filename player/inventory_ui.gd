extends MarginContainer

const ITEM_DISP = preload("uid://ie2w7o88drlw")

@onready var parent:ColorRect = $"../"
@onready var inventory:GridInventory = %Inventory
@onready var equipped_disp:Control = $"../../EquippedDisp"
# @onready var inv_grid:GridContainer = %InventoryGrid

@export var body_slots:Array[PlayerSlot]

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		parent.visible = !parent.visible
		equipped_disp.visible = !parent.visible
		if !parent.visible:
			get_viewport().gui_cancel_drag()
	if event.is_action_pressed("hand_swap"):
		body_slots[0].swap_item(body_slots[1])
	if event.is_action_pressed("l_hip_swap"):
		body_slots[0].swap_item(body_slots[3])
	if event.is_action_pressed("r_hip_swap"):
		body_slots[0].swap_item(body_slots[2])
