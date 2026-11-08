class_name LevelBuilder

# transformes the level data into a level scene contents to be loaded into world
static func build_tilemap(level:LevelData) -> LevelSceneContents:
	var contents := LevelSceneContents.new()

	contents.solid_mask.resize(level.level_size.x)
	for cx in contents.solid_mask.size():
		contents.solid_mask[cx] = []
		contents.solid_mask[cx].resize(ceili(level.level_size.y / 8.0))
		contents.solid_mask[cx].fill(0)

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

	# genuinly dont know why i decided to use a 2d byte array isntead of a 2d bool aray
	# maybe it shaves 1 nanosecond off of the 1 second load time or something
	# get mask for pathfinding
	for cell in base_tilemap.get_used_cells():
		var tile := base_tilemap.get_cell_tile_data(cell)
		if tile and tile.get_collision_polygons_count(0) > 0:
			_mark_solid(contents.solid_mask, cell)

	for cell in mid_tilemap.get_used_cells():
		var tile := mid_tilemap.get_cell_tile_data(cell)
		if tile == null or tile.get_collision_polygons_count(0) == 0:
			continue

		var footprint := Vector2i.ONE
		var source := mid_tilemap.tile_set.get_source(mid_tilemap.get_cell_source_id(cell)) as TileSetAtlasSource
		if source:
			footprint = source.get_tile_size_in_atlas(mid_tilemap.get_cell_atlas_coords(cell))
		else:
			printerr("cannot get source of tile when creating pathfinding mask")

		for dx in footprint.x:
			for dy in footprint.y:
				_mark_solid(contents.solid_mask, cell + Vector2i(dx, dy))

	# spawn props
	for p in level.props.size():
		var node:Node2D = Global.prop_library.get_prop_node(level.props[p])
		if !node: continue
		node.position = level.prop_positions[p] * 16
		# TODO: put the prop data into the actual prop

		contents.props.append(node)

	for e in level.entities.size():
		var entity:Entity = Global.entity_library.get_entity_node(level.entities[e])
		if !entity: continue
		entity.position = level.entity_positions[e] * 16

		contents.entities.append(entity)


	return contents

static func _mark_solid(mask: Array, cell: Vector2i) -> void:
	if cell.x < 0 or cell.x >= mask.size() or cell.y < 0:
		return
	var column: PackedByteArray = mask[cell.x]
	var byte := cell.y >> 3
	if byte >= column.size():
		return
	column[byte] |= 1 << (cell.y & 7)
	mask[cell.x] = column
