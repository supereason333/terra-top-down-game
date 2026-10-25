extends Node

signal wave_started(wave: int)
signal wave_ended(wave: int)

const ENEMY: PackedScene = preload("uid://c4j1livh1e7bi")

@onready var entities_node: Node2D = $"../Entities"
@onready var tilemap: TileMapLayer = $"../TileMapLayer"
@onready var player: Player = $"../Player"
@onready var wave_label:Label = $"../WaveLabel"
@onready var death_label:Label = $"../DeathCounter"

@export var min_spawn_distance := 120.0
@export var base_enemies := 5
@export var enemies_per_wave := 2
@export var spawn_interval := 0.3
@export var wave_delay := 3.0

var wave := 0
var spawn_target := 0
var spawned := 0
var alive := 0
var spawn_cells: Array[Vector2i] = []

var spawn_timer := 0.0
var wave_countdown := 0.0
var between_waves := true

func _ready() -> void:
	set_process(false)

func start() -> void:
	wave_label.show()
	death_label.show()
	wave = 0
	_build_spawn_cells()
	if spawn_cells.is_empty():
		push_error("WaveSpawner: no spawnable tiles")
		return
	between_waves = true
	wave_countdown = 0.0
	set_process(true)

func stop() -> void:
	set_process(false)

func _process(delta: float) -> void:
	if between_waves:
		wave_countdown -= delta
		if wave_countdown <= 0.0:
			_begin_wave()
		return

	if spawned < spawn_target:
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			spawn_timer = spawn_interval
			_spawn_enemy()
	elif alive <= 0:
		_end_wave()

func _begin_wave() -> void:
	wave += 1
	spawn_target = base_enemies + (wave - 1) * enemies_per_wave
	spawned = 0
	alive = 0
	spawn_timer = 0.0
	between_waves = false
	wave_started.emit(wave)

	wave_label.text = "wave: %d" % wave

func _end_wave() -> void:
	between_waves = true
	wave_countdown = wave_delay
	wave_ended.emit(wave)

func _build_spawn_cells() -> void:
	spawn_cells.clear()
	var layer_count := tilemap.tile_set.get_physics_layers_count()
	for cell in tilemap.get_used_cells():
		var data := tilemap.get_cell_tile_data(cell)
		if data == null:
			continue
		var blocked := false
		for layer in layer_count:
			if data.get_collision_polygons_count(layer) > 0:
				blocked = true
				break
		if not blocked:
			spawn_cells.append(cell)

func _pick_spawn_position() -> Variant:
	var min_sq := min_spawn_distance * min_spawn_distance
	for i in 30:
		var cell: Vector2i = spawn_cells.pick_random()
		var pos := tilemap.to_global(tilemap.map_to_local(cell))
		if pos.distance_squared_to(player.global_position) >= min_sq:
			return pos
	return null

func _spawn_enemy() -> void:
	var pos = _pick_spawn_position()
	if pos == null:
		return # retried on the next interval

	var enemy := ENEMY.instantiate() as Node2D
	entities_node.add_child(enemy)
	enemy.global_position = pos
	enemy.tree_exited.connect(_on_enemy_removed, CONNECT_ONE_SHOT)
	spawned += 1
	alive += 1

	death_label.text = "%d/%d" % [alive, spawned]

func _on_enemy_removed() -> void:
	alive -= 1

	death_label.text = "%d/%d" % [alive, spawned]
