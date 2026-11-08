class_name LevelBuilder

static func build_tilemap(level:LevelData) -> LevelSceneContents:
	var contents := LevelSceneContents.new()

	var tilemap := TileMapLayer.new()
	tilemap.tile_set = Global.tile_library.tileset

	for x in level.base_tiles.size():
		for y in level.base_tiles[x].size():
			var tile = Global.tile_library.get_tile(level.base_tiles[x][y])
			tilemap.set_cell(Vector2i(x, y), tile[0], tile[1], tile[2])

	tilemap.z_index = -2
	contents.base_tilemap = tilemap

	# spawn props
	for p in level.props.size():
		var node:Node2D = Global.prop_library.get_prop_node(level.props[p])
		if !node: continue
		node.position = level.prop_positions[p] * 16
		# TODO: put the prop data into the actual prop

		contents.props.append(node)

	# TODO: Spawn entities


	return contents
