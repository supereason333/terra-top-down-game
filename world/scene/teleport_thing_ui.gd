extends Control

const CELLS_NEEDED = 3

@onready var canvas:CanvasLayer = $".."

@onready var next_world_box:VBoxContainer = $NextBox
@onready var position_label:Label = $PositionLabel
@onready var cell_label:Label = $CellLabel

var cells:int = 0

func _ready() -> void:
	_on_canvas_layer_visibility_changed()
	var world := GameMngr.get_world()
	if world:
		world.loaded_new_level.connect(_on_new_level)
		# print("connect")
	# update_display()

func _shortcut_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		canvas.hide()
	get_viewport().set_input_as_handled()

func _on_canvas_layer_visibility_changed() -> void:
	if canvas.visible:
		set_process_shortcut_input(true)
		GameMngr.get_player().hide_ui_canvas()
	else:
		set_process_shortcut_input(false)
		GameMngr.get_player().show_ui_canvas()

func _on_new_level(_pos:PackedInt32Array):
	update_display()

func update_display():
	for child in next_world_box.get_children():
		child.queue_free()
	var world := GameMngr.get_world()
	if !world: return
	# print(world.branching)
	for b in world.branching.size():
		var btn := Button.new()
		btn.text = str("-[%d]-" % b)
		btn.pressed.connect(_next_world_pressed.bind(b))
		next_world_box.add_child(btn)
	position_label.text = "Position: [ "
	for item in world.level_position:
		position_label.text += ("%d, " % item)
	position_label.text.trim_suffix(", ")
	position_label.text += " ]"

	cell_label.text = "Cells: %d/%d" % [cells, CELLS_NEEDED]

func _next_world_pressed(id:int):
	if cells < CELLS_NEEDED:
		$CellWarnLabel.show()
		return
	$CellWarnLabel.hide()
	var world := GameMngr.get_world()
	if !world: return
	cells = 0
	world.load_next(id)


func _on_give_cells_pressed() -> void:
	if cells >= CELLS_NEEDED: return
	var player := GameMngr.get_player()
	if !player: return
	var inv := player.get_inventory()
	if !inv: return
	var loci := inv.find_item(&"power_cell")
	if loci == -1: return
	inv.take_item(loci)
	cells += 1

	cell_label.text = "Cells: %d/%d" % [cells, CELLS_NEEDED]
