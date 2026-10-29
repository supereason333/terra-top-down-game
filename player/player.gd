extends Entity
class_name Player

@onready var ui_canvas:CanvasLayer = $CanvasLayer

@onready var gun_rotate: Node2D = $GunRotate

@export var walk_speed := 40.0
@export var sprint_speed := 60.0
## Velocity-error to acceleration gain (1/s). Higher = snappier.
@export var response := 10.0
## Maximum force applied per physics step.
@export var max_force := 600.0

func _physics_process(_dt: float) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var target_speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	var velocity_error := input_dir * target_speed - linear_velocity
	apply_central_force((velocity_error * response * mass).limit_length(max_force))

func _process(_dt: float) -> void:
	gun_rotate.rotation = get_local_mouse_position().angle()

func _kill():
	get_tree().change_scene_to_file("res://death_screen.tscn")

func get_inventory() -> Inventory:
	return %Inventory

func get_health() -> HealthNode:
	return %HealthNode

func hide_ui_canvas():
	ui_canvas.hide()

func show_ui_canvas():
	ui_canvas.show()
