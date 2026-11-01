extends EntityAI

@onready var entity:RigidBody2D = $".."

@export var vision:Area2D
@export var movement:EntityMovement
@export var rotate_node:Node2D
@export var inventory:Inventory
@export var equip_point:EquipPoint
@export var vision_raycast:RayCast2D

@export var direct_chase_radius := 16.0
var direct_chase_radius_sq: float:
	get(): return direct_chase_radius * direct_chase_radius
@export var attack_radius := 10.0
var attack_radius_sq: float:
	get(): return attack_radius * attack_radius
@export var attack_cooldown:float = 1.0


# null = idle, else chase
var player:Player
var last_seen_pos:Vector2
var seen_player:bool = false
var world:World
var out_of_vision_timer:Timer
var idle_move_timer:Timer
var attack_cooldown_timer:Timer

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

	attack_cooldown_timer = Timer.new()
	attack_cooldown_timer.wait_time = attack_cooldown
	attack_cooldown_timer.name = "AttackCooldownTimer"
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.autostart = false
	add_child(attack_cooldown_timer)

func _ai_update():
	# if !is_node_ready(): return
	if player:
		vision_raycast.target_position = vision_raycast.to_local(player.global_position)
		vision_raycast.force_raycast_update()
		var see_player := vision_raycast.get_collider() is Player

		var target_pos: Vector2
		if see_player:
			target_pos = player.global_position
			last_seen_pos = target_pos
			seen_player = true
		else:
			target_pos = last_seen_pos

		if seen_player:
			var dist_sq := entity.global_position.distance_squared_to(target_pos)

			if see_player and dist_sq <= attack_radius_sq and attack_cooldown_timer.is_stopped():
				equip_point.use()
				attack_cooldown_timer.start()

			if see_player and dist_sq <= direct_chase_radius_sq:
				movement.set_target(target_pos, false)
			elif movement.path.is_empty() \
			or movement.path_type != EntityMovement.PathType.POINTS \
			or target_pos.distance_squared_to(movement.path[movement.path.size() - 1]) >= 64:
				movement.set_target(target_pos)
	else:
		if idle_move_timer.is_stopped():
			idle_move_timer.wait_time = randf_range(3, 10)
			idle_move_timer.start()

	if rotate_node:
		if !movement.heading.is_zero_approx():
			rotate_node.rotation = movement.heading.angle()

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
	seen_player = false
