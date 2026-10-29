extends Node2D
class_name World

signal loaded_new_level(pos:PackedInt32Array)

@onready var player:Player = $Player

@onready var projectiles:Node2D = $Projectiles
@onready var entities:Node2D = $Entities
var tilemap:TileMapLayer

@onready var enemy_movement:EntityMovement = $BasicEnemy/EntityMovement

var astar := AStarGrid2D.new()

# game world stuff
var world_data:WorldData
var level_position:PackedInt32Array
var current_level_data:LevelData
var branching:Array[LevelDisplayData]

func _ready() -> void:
	var s := randi()
	print("Seed: %d" % s)
	init_world(s)

func setup_astar():
	var used_rect: Rect2i = tilemap.get_used_rect()
	astar.region = used_rect
	astar.cell_size = tilemap.tile_set.tile_size
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER # Adjust as needed
	astar.update()

	for cell in tilemap.get_used_cells():
		var source_id := tilemap.get_cell_source_id(cell)
		if source_id == -1: continue
		var tile := tilemap.get_cell_tile_data(cell)
		if tile == null: continue
		if tile.get_collision_polygons_count(0) > 0:
			astar.set_point_solid(cell)

func register_projectile(proj:Projectile):
	projectiles.add_child(proj)

func init_world(world_seed:int):
	world_data = WorldData.new(world_seed)
	level_position = []
	branching = WorldGenerator.get_branching(world_data.world_seed, [])

	load_level([])

func load_level(level_pos:PackedInt32Array):
	# Unload level
	for child in projectiles.get_children():
		child.queue_free()
	for child in entities.get_children():
		child.queue_free()

	if tilemap:
		tilemap.queue_free()
		tilemap = null

	current_level_data = null

	# Load new data
	level_position = level_pos
	current_level_data = WorldGenerator.generate_level(world_data.world_seed, level_position)
	branching = WorldGenerator.get_branching(world_data.world_seed, level_position)

	# Load new level
	tilemap = LevelBuilder.build_tilemap(current_level_data)
	tilemap.collision_enabled = false
	add_child(tilemap)

	var rect:Rect2i = tilemap.get_used_rect()
	rect.position *= tilemap.tile_set.tile_size
	rect.size *= tilemap.tile_set.tile_size
	player.set_camera_rect(rect)

	loaded_new_level.emit(level_position)
