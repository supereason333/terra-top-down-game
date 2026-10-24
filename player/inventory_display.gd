extends VBoxContainer

const ITEM_DISP:PackedScene = preload("uid://c8efhshtwf38q")

@onready var inventory:Inventory = %Inventory

var disps:Array[InvItemDisp]

func _ready() -> void:
	inventory.equipped_changed.connect(update_equipped)
	inventory.items_changed.connect(update_items)
	update_items()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		$"../../..".visible = !$"../../..".visible

func update_items():
	for child in get_children(): child.queue_free()
	disps.clear()
	var i := 0
	for item in inventory.inv:
		var disp:InvItemDisp = ITEM_DISP.instantiate()
		disp.item = item
		disp.slot = i
		if i == inventory.equipped:
			disp.selected = true
		add_child(disp)
		disp.btn.pressed.connect(_on_checkbox.bind(i, disp.btn))
		disps.append(disp)
		i += 1

func update_equipped(slot_new:int, slot_old:int):
	disps[slot_old].selected = false
	if slot_new != -1: disps[slot_new].selected = true

func _on_checkbox(slot:int, btn:CheckBox):
	if btn.button_pressed:
		inventory.set_equipped(slot)
	else:
		inventory.set_equipped(-1)
