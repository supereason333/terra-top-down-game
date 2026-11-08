class_name LevelBuilder

static func build_tilemap(level:LevelData) -> LevelSceneContents:
	var contents := LevelSceneContents.new()

	var base_tilemap := TileMapLayer.new()
	var mid_tilemap := TileMapLayer.new()
	var top_tilemap := TileMapLayer.new()

	base_tilemap.tile_set = Global.tile_library.tileset
	mid_tilemap.tile_set = Global.tile_library.tileset
	top_tilemap.tile_set = Global.tile_library.tileset

	base_tilemap.z_index = -3
	mid_tilemap.z_index = -2
	top_tilemap.z_index = -1

	for x in level.base_tiles.size():
		for y in level.base_tiles[x].size():
			if level.base_tiles[x][y] == 0: continue
			var tile = Global.tile_library.get_tile(level.base_tiles[x][y])
			base_tilemap.set_cell(Vector2i(x, y), tile[0], tile[1], tile[2])

	for x in level.mid_tiles.size():
		for y in level.mid_tiles[x].size():
			if level.mid_tiles[x][y] == 0: continue
			var tile = Global.tile_library.get_tile(level.mid_tiles[x][y])
			mid_tilemap.set_cell(Vector2i(x, y), tile[0], tile[1], tile[2])

	# TODO: add top tilemap but currentnetly not used so like not needed

	contents.base_tilemap = base_tilemap
	contents.mid_tilemap = mid_tilemap
	contents.uppper_tilemap = top_tilemap


	# spawn props
	for p in level.props.size():
		var node:Node2D = Global.prop_library.get_prop_node(level.props[p])
		if !node: continue
		node.position = level.prop_positions[p] * 16
		# TODO: put the prop data into the actual prop

		contents.props.append(node)

	# TODO: Spawn entities


	return contents
