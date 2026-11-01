extends MarginContainer

const ITEM_DISP = preload("uid://ie2w7o88drlw")

@onready var parent:ColorRect = $"../"
@onready var inventory:GridInventory = %Inventory
# @onready var inv_grid:GridContainer = %InventoryGrid

@export var body_slots:Array[ColorRect]

var mouse_over:int = -1

func _ready() -> void:
	pass

func _mouse_entered_tile(i:int):
	mouse_over = i

func _mouse_exited_tile(i:int):
	if mouse_over == i:
		mouse_over = -1
