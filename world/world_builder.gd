class_name LevelBuilder

# TODO: Make level builder
static func build_tilemap(level:LevelData) -> LevelSceneContents:
	var contents := LevelSceneContents.new()

	var tilemap := TileMapLayer.new()
	tilemap.tile_set = Global.tile_library.tileset

	for x in level.world_tiles.size():
		for y in level.world_tiles[x].size():
			if level.world_tiles[x][y]:
				tilemap.set_cell(Vector2i(x, y), 0, Vector2i(1, 0))

	contents.tilemap = tilemap

	for room in level.rooms:
		if room.entities.is_empty(): continue
		for e in room.entities.size():
			var new:Entity = Global.entity_library.get_entity_node(room.entities[e])
			new.position = Vector2(room.rect.position) + room.entity_positions[e]
			new.position *= 16
			contents.entities.append(new)

	return contents
