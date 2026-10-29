extends Node2D
class_name World

@onready var projectiles:Node2D = $Projectiles
@onready var tilemap:TileMapLayer = $TileMapLayer

@onready var enemy_movement:EntityMovement = $BasicEnemy/EntityMovement

var astar := AStarGrid2D.new()

# game world stuff
var world_data:WorldData
var current_position:PackedInt32Array
var current_level_data:LevelData
var next_options:PackedInt32Array

func _ready() -> void:
	world_data = WorldData.new(123123123)
	current_position = []

	print(tilemap.tile_set.get_source_id(0))

	var source = tilemap.tile_set.get_source(0)
	print(source.get_tiles_count())
	print(source.get_tile_id(0))
	print(source.get_tile_id(1))
	print(source.get_tile_id(2))
	print(source.get_tile_id(3))


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

func next_level(id:int):
	unload_level()
	load_next(id)

func unload_level() -> void:
	pass

func load_next(id:int) -> void:
	pass
