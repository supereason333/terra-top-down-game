extends EntityAI

@onready var entity:RigidBody2D = $".."

@export var vision:Area2D
@export var movement:EntityMovement

# null = idle, else chase
var player:Player
var world:World
var out_of_vision_timer:Timer
var idle_move_timer:Timer

func _ready() -> void:
	if !vision:
		printerr("Entity AI has no vision")
		queue_free()
		return
	world = GameMngr.get_world()
	if !world:
		printerr("Entity AI cannot get world")
		queue_free()
		return
	AiMngr.register(self)

	vision.body_entered.connect(_on_body_entered_vision)
	vision.body_exited.connect(_on_body_exited_vision)
	var timer := Timer.new()
	timer.name = "OutOfVisionTimer"
	timer.wait_time = 0.5
	timer.autostart = false
	timer.one_shot = true
	timer.timeout.connect(_on_out_of_vision_timeout)
	out_of_vision_timer = timer
	add_child(timer)

	idle_move_timer = Timer.new()
	idle_move_timer.name = "IdleMoveTimer"
	idle_move_timer.one_shot = true
	idle_move_timer.autostart = false
	add_child(idle_move_timer)

func _ai_update():
	if player:
		if movement.path.is_empty():
			movement.set_target(player.position)
		elif player.position.distance_squared_to(movement.path[movement.path.size() - 1]) >= 64: # 6^2 * 2
			movement.set_target(player.position)
			print("AWDAWDAWD")
	else:
		if idle_move_timer.is_stopped():
			idle_move_timer.wait_time = randf_range(3, 10)
			idle_move_timer.start()

func _on_body_entered_vision(body:Node2D) -> void:
	if body is Player:
		player = body
		out_of_vision_timer.stop()

func _on_body_exited_vision(body:Node2D) -> void:
	if body == player:
		out_of_vision_timer.start()

func _on_out_of_vision_timeout() -> void:
	player = null
	movement.clear_path()
