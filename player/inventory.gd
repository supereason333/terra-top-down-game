extends Inventory
class_name GridInventory

signal item_added(i: int)
signal item_pos_changed(i: int)
signal item_removed(item: Item2D)

@export var preload_grid: Array[PreloadInvItem]
@export var inv_size := Vector2i(5, 10)

var positions: Array[Vector2i] = []  # positions[i] = top-left cell of inv[i]
var cells: Array[Array] = []  # cells[x][y] = true if occupied

func _ready() -> void:
	# Base _ready is not called
	for x in inv_size.x:
		var column := []
		column.resize(inv_size.y)
		column.fill(false)
		cells.append(column)

	for entry in preload_grid:
		var item := _spawn(entry.id)
		if item:
			place_item(entry.position, item)

	for id in preload_inv:
		for n in preload_inv[id]:
			var item := _spawn(id)
			if item:
				add_item(item)

func _spawn(id: StringName) -> Item2D:
	var item := Global.item_library.get_item_node(id)
	if item == null:
		print_debug("Item get node null: ", id)
	return item

# overrides Inventory.add_item, puts the item in the first free spot
func add_item(new: Item2D, _slot: int = -1) -> bool:
	if new == null:
		return false
	var cell := find_free_cell(new.size)
	if cell == Vector2i(-1, -1):
		return false
	return place_item(cell, new)

# places the item at a specific cell.
func place_item(cell: Vector2i, item: Item2D) -> bool:
	if item == null or not can_fit(cell, item.size):
		return false
	inv.append(item)
	positions.append(cell)
	fill_area(cell, item.size, true)
	item_added.emit(inv.size() - 1)
	items_changed.emit()
	return true

func take_item(slot: int) -> Item2D:
	if slot < 0 or slot >= inv.size():
		return null
	var item := inv[slot]
	fill_area(positions[slot], item.size, false)
	inv.remove_at(slot)
	positions.remove_at(slot)
	item_removed.emit(item)
	items_changed.emit()
	return item

# swaps the grid positions of two items.
func swap_item(a: int, b: int):
	if a == b or a < 0 or b < 0 or a >= inv.size() or b >= inv.size():
		return
	var pos_a := positions[a]
	var pos_b := positions[b]
	fill_area(pos_a, inv[a].size, false)
	fill_area(pos_b, inv[b].size, false)

	if can_fit(pos_b, inv[a].size):
		fill_area(pos_b, inv[a].size, true)
		if can_fit(pos_a, inv[b].size):
			fill_area(pos_a, inv[b].size, true)
			positions[a] = pos_b
			positions[b] = pos_a
			item_pos_changed.emit(a)
			item_pos_changed.emit(b)
			items_changed.emit()
			return
		fill_area(pos_b, inv[a].size, false)

	# swap doesnt fit so restore both
	fill_area(pos_a, inv[a].size, true)
	fill_area(pos_b, inv[b].size, true)

func find_item(id: StringName, _in_reserved: bool = false) -> int:
	for i in inv.size():
		if inv[i].id == id:
			return i
	return -1

func find_item_class(item:Item2D, _in_reserved:bool = false) -> int:
	for i in inv.size():
		if inv[i] == item:
			return i
	return -1

func change_position(i: int, new_pos: Vector2i) -> bool:
	if i < 0 or i >= inv.size() or new_pos == positions[i]:
		return false
	var old_pos := positions[i]
	var item_size := inv[i].size
	fill_area(old_pos, item_size, false)  # free own cells so the item can overlap its old spot
	if not can_fit(new_pos, item_size):
		fill_area(old_pos, item_size, true)
		return false
	positions[i] = new_pos
	fill_area(new_pos, item_size, true)
	item_pos_changed.emit(i)
	items_changed.emit()
	return true

func can_fit(cell: Vector2i, item_size: Vector2i) -> bool:
	var end := cell + item_size  # exclusive
	if cell.x < 0 or cell.y < 0 or end.x > inv_size.x or end.y > inv_size.y:
		return false
	for x in range(cell.x, end.x):
		for y in range(cell.y, end.y):
			if cells[x][y]:
				return false
	return true

func find_free_cell(item_size: Vector2i) -> Vector2i:
	for y in range(inv_size.y - item_size.y + 1):
		for x in range(inv_size.x - item_size.x + 1):
			if can_fit(Vector2i(x, y), item_size):
				return Vector2i(x, y)
	return Vector2i(-1, -1)

func fill_area(from: Vector2i, item_size: Vector2i, value: bool) -> void:
	for x in range(from.x, from.x + item_size.x):
		for y in range(from.y, from.y + item_size.y):
			cells[x][y] = value

func pick_item_from_grid(cell: Vector2i) -> int:
	for i in inv.size():
		if Rect2i(positions[i], inv[i].size).has_point(cell):
			return i
	return -1
