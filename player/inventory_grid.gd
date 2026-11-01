extends Control

const DISP_SCENE = preload("uid://ie2w7o88drlw")
const SEPERATION = 4

@onready var inventory:GridInventory = %Inventory
@onready var grid:GridContainer = $Grid
@onready var item_disp:Control = $ItemDisp

var tile_size:int = 36

var last_drag_data:InvDragData

func _ready() -> void:
	custom_minimum_size.x = grid.size.x
	grid.columns = inventory.inv_size.x
	for child in grid.get_children(): child.queue_free()
	for i in inventory.inv_size.x * inventory.inv_size.y:
		var rect := ColorRect.new()
		rect.custom_minimum_size = Vector2i(tile_size, tile_size)
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# print(rect.size)
		rect.color = Color("8c8c8c")
		grid.add_child(rect)

	inventory.item_added.connect(_item_added)
	inventory.item_removed.connect(_item_removed)
	inventory.item_pos_changed.connect(_item_pos_changed)

	update_display()

func _item_added(i:int) -> void:
	update_display()

func _item_removed(item:Item2D) -> void:
	update_display()

func _item_pos_changed(i:int) -> void:
	update_display()

func update_display():
	for child in item_disp.get_children(): child.queue_free()
	for i in inventory.inv.size():
		var disp:InvItemDisp = DISP_SCENE.instantiate()
		disp.item = inventory.inv[i]
		disp.position = inventory.positions[i] * (tile_size + SEPERATION)
		item_disp.add_child(disp)

func _get_drag_data(at_position: Vector2) -> Variant:
	var grid_pos := local_to_grid(at_position)
	var i := inventory.pick_item_from_grid(grid_pos)
	if i == -1: return
	print(grid_pos)
	var item := inventory.inv[i]
	if !item: return null

	var data := InvDragData.new(item)
	data.drop_successful.connect(_drop_recieved.bind(i))

	var label := Label.new()
	label.text = item.id
	set_drag_preview(label)
	last_drag_data = data
	return data

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is InvDragData: return true
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if data is InvDragData:
		if data == last_drag_data:
			var id := inventory.find_item_class(data.item)
			if id == -1: return
			inventory.change_position(id, local_to_grid(at_position))
			return
		if inventory.place_item(local_to_grid(at_position), data.item):
			data.drop_successful.emit()

func _drop_recieved(remove:int):
	inventory.take_item(remove)

func local_to_grid(local:Vector2) -> Vector2i:
	@warning_ignore("narrowing_conversion")
	return Vector2i(local.x / (tile_size + SEPERATION), local.y / (tile_size + SEPERATION))
