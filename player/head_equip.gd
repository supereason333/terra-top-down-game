extends Marker2D

@export var source:Entity
@export var slot:PlayerSlot

var equipped:Item2D

func _ready() -> void:
	if !slot: return
	slot.item_changed.connect(_item_changed)

func _item_changed(item:Item2D):
	if item == equipped: return
	if equipped:
		remove_child(equipped)
	equipped = item
	if item:
		add_child(item)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("use_head_slot"):
		use()

func use():
	if equipped:
		equipped.use(source)
#
# func _use(_source:Entity):
# 	pass
