extends Resource
class_name TileLibrary

@export var library:Dictionary[int, TileDataResource]
## Tileset ext resource, should only be read
@export var tileset:TileSet

var initilized := false

func initilize():
	# sets stuff each tile resource
	for key in library.keys():
		pass

	var total_tiles_checked := 0
	var registered_tiles := 0

	# search tilesets to find tiles
	var source_amount := tileset.get_source_count()
	var checked_sources := 0
	var s := 0
	while checked_sources < source_amount:
		var source_id = tileset.get_source_id(s)
		if source_id == -1:
			s += 1
			continue
		checked_sources += 1
		var source := tileset.get_source(source_id) as TileSetAtlasSource
		var tile_count := source.get_tiles_count()
		var checked_tiles := 0
		var t := 0
		while checked_tiles < tile_count:
			var atlas_coords := source.get_tile_id(t)
			if atlas_coords == Vector2i(-1, -1):
				t += 1
				continue
			checked_tiles += 1
			for alt in source.get_alternative_tiles_count(atlas_coords):
				total_tiles_checked += 1
				var data := source.get_tile_data(atlas_coords, 0)
				if !data: continue
				if register_tile(data, source_id, atlas_coords, alt): registered_tiles += 1

			t += 1
		s += 1

	initilized = true

	print("Tile library initilized")
	print("Checked %d tiles, registered %d tiles" % [total_tiles_checked, registered_tiles])

func register_tile(tile:TileData, source_id:int, atlas_coords:Vector2i, alternate_id:int) -> bool:
	if !tile.has_custom_data("tile_id"): return false
	var id:int = tile.get_custom_data("tile_id")
	if !library.has(id): return false
	library[id].source_id.append(source_id)
	library[id].atlas_coords.append(atlas_coords)
	library[id].alternate_id.append(alternate_id)

	return true

func id_from_num_id(id:int) -> StringName:
	return ""
