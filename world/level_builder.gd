class_name LevelBuilder

# TODO: Make level builder
static func build_tilemap(level:LevelData) -> LevelSceneContents:
	var contents := LevelSceneContents.new()

	var tilemap := TileMapLayer.new()
	tilemap.tile_set = Global.tile_library.tileset

	for x in level.base_tiles.size():
		for y in level.base_tiles[x].size():
			if level.base_tiles[x][y]:
				tilemap.set_cell(Vector2i(x, y), 0, Vector2i(1, 0))

	contents.base_tilemap = tilemap

	# TODO: Spawn entities


	return contents
