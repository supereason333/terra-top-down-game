extends CharacterBody2D
class_name Player

@onready var gun_rotate:Node2D = $GunRotate

var walk_speed := 40
var sprint_speed := 60

func _ready() -> void:
	pass

func _physics_process(_dt: float) -> void:
	var dir = Input.get_vector("left", "right", "up", "down").normalized()
	if Input.is_action_pressed("sprint"): velocity = dir * sprint_speed
	else: velocity = dir * walk_speed

	move_and_slide()


func _process(_dt: float) -> void:
	var angle:float = get_local_mouse_position().angle()
	gun_rotate.rotation = angle
