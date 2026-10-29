class_name LevelBuilder

# TODO: Make level builder
static func build_tilemap(level:LevelData) -> TileMapLayer:
	var tilemap := TileMapLayer.new()
	tilemap.tile_set = Global.tile_library.tileset

	for x in level.world_tiles.size():
		for y in level.world_tiles[x].size():
			if level.world_tiles[x][y]:
				tilemap.set_cell(Vector2i(x, y), 0, Vector2i(1, 0))

	return tilemap
