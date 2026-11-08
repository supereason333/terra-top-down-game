extends Node2D
class_name World

signal loaded_new_level(pos:PackedInt32Array)

@onready var player:Player = $Player
@onready var teleport_thing:Node2D = $TeleportThing

@onready var projectiles:ProjectileMngr = %Projectiles
@onready var entities:EntityMngr = %Entities
@onready var items:ItemDropMngr = %Items
@onready var props:Node2D = %Props
var base_tilemap:TileMapLayer
var mid_tilemap:TileMapLayer
var top_tilemap:TileMapLayer

# @onready var enemy_movement:EntityMovement = $BasicEnemy/EntityMovement

var astar := AStarGrid2D.new()
var pathfind_mask:Array[PackedByteArray]

# game world stuff
var world_data:WorldData
var level_position:PackedInt32Array
var current_level_data:LevelData
var branching:Array[LevelDisplayData]

func _ready() -> void:
	GameMngr.level = 0
	var s := randi()
	print("Seed: %d" % s)
	init_world(s)

func init_world(world_seed:int):
	world_data = WorldData.new(world_seed)
	level_position = []
	branching = WorldGenerator.get_branching(world_data.world_seed, [])

	load_level([])

func load_next(id:int):
	level_position.append(id)
	load_level(level_position)

func load_level(level_pos:PackedInt32Array):
	# Unload level
	for child in projectiles.get_children():
		child.queue_free()
	for child in entities.get_children():
		child.queue_free()
	for child in props.get_children():
		child.queue_free()

	if base_tilemap:
		base_tilemap.queue_free()
		base_tilemap = null
	if mid_tilemap:
		mid_tilemap.queue_free()
		mid_tilemap = null
	if top_tilemap:
		top_tilemap.queue_free()
		top_tilemap = null

	current_level_data = null

	projectiles.clear_projectiles()
	entities.clear_entities()

	# Load new data
	level_position = level_pos
	# "UwU"
	#  - Zach Brevoort
	current_level_data = WorldGenerator.generate_level(world_data.world_seed, level_position)
	branching = WorldGenerator.get_branching(world_data.world_seed, level_position)

	# Load new level
	var contents = LevelBuilder.build_tilemap(current_level_data)
	base_tilemap = contents.base_tilemap
	mid_tilemap = contents.mid_tilemap
	top_tilemap = contents.uppper_tilemap
	add_child(base_tilemap)
	add_child(mid_tilemap)
	add_child(top_tilemap)

	for prop in contents.props:
		props.add_child(prop)

	for entity in contents.entities:
		entities.register_entity(entity)

	var rect:Rect2i = base_tilemap.get_used_rect()
	rect.position *= base_tilemap.tile_set.tile_size
	rect.size *= base_tilemap.tile_set.tile_size
	pathfind_mask = contents.solid_mask
	setup_astar()
	# player.set_camera_rect(rect)		# change: DONT SET CAMERA RECT, if not good reset this here!!!!! it might make world feel bigger idk

	player.queue_pos_reset(current_level_data.spawn_pos * 16)
	teleport_thing.position = current_level_data.teleport_thing_pos * 16
	GameMngr.level += 1
	# print("emit")
	loaded_new_level.emit(level_position)

func setup_astar() -> void:
	var level_size := current_level_data.level_size
	astar.region = Rect2i(Vector2i.ZERO, level_size)
	astar.cell_size = Vector2(base_tilemap.tile_set.tile_size)
	# astar.offset = astar.cell_size * 0.5
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()

	for cx in level_size.x:
		for ry in level_size.y:
			if (pathfind_mask[cx][ry >> 3] >> (ry & 7)) & 1:
				astar.set_point_solid(Vector2i(cx, ry))

func get_projectiles() -> ProjectileMngr:
	return projectiles

func get_entities() -> EntityMngr:
	return entities

func get_items() -> ItemDropMngr:
	return items
