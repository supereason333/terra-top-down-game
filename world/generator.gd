class_name WorldGenerator

const MAX_SIZE_TILES = 100
const MIN_SIZE_TILES = 80

const MIN_ROOM_SIZE = 4		# for 3x3 room

@warning_ignore_start("integer_division")
# static func generate_level(level_seed:int, settings:LevelGeneratorSettings) -> LevelData:
static func generate_level(world_seed:int, level_position:PackedInt32Array) -> LevelData:
	var rand := RandomNumberGenerator.new()
	rand.seed = SeedUtil.combine(world_seed, hash(level_position))
	var level_size:Vector2i = Vector2i(
		rand.randi_range(MIN_SIZE_TILES, MAX_SIZE_TILES),
		rand.randi_range(MIN_SIZE_TILES, MAX_SIZE_TILES)
	)
	var level = LevelData.new(level_size)
	var rooms:Array[Rect2i]
	rooms.append(Rect2i(Vector2i.ZERO, level_size))

	# 36 is ave room size (6*6), how many divisions for BSP
	var room_target:int = level_size.x * level_size.y / 64
	var large_rooms:Array[int] = [0]	# Rooms that are large enough to divide

	# Divide rooms
	for div in room_target:
		if large_rooms.is_empty(): break
		var i = rand.randi_range(0, large_rooms.size() - 1)
		var room = rooms[large_rooms[i]]
		var divide := rand.randi_range(MIN_ROOM_SIZE, maxi(room.size.x, room.size.y) - MIN_ROOM_SIZE - 1)
		var new:Rect2i
		if room.size.x > room.size.y:	# slice room verticaly
			new = Rect2i(
				room.position + Vector2i(divide + 1, 0),
				Vector2i(room.size.x - divide - 1, room.size.y)
			)
			rooms[large_rooms[i]].size.x = divide
		else:
			new = Rect2i(
				room.position + Vector2i(0, divide + 1),
				Vector2i(room.size.x, room.size.y - divide - 1)
			)
			rooms[large_rooms[i]].size.y = divide
		rooms.append(new)
		room = rooms[large_rooms[i]]
		if maxi(room.size.x, room.size.y) < MIN_ROOM_SIZE * 2 + 1:
			large_rooms.remove_at(i)
		if maxi(new.size.x, new.size.y) >= MIN_ROOM_SIZE * 2 + 1:
			large_rooms.append(rooms.size() - 1)

	# TODO: Find and create doorways

	# Create mask of solid or not
	var y_bytes := ceili(level_size.y / 8.0)
	var mask: Array[PackedByteArray] = []
	for x in level_size.x:
		var column := PackedByteArray()
		column.resize(y_bytes)
		column.fill(0xFF)
		mask.append(column)

	var bounds := Rect2i(Vector2i.ZERO, level_size)
	for room in rooms:
		var r := room.abs().intersection(bounds)
		for x in range(r.position.x, r.end.x):
			var column := mask[x]
			for y in range(r.position.y, r.end.y):
				column[y >> 3] &= ~(1 << (y & 7))
			mask[x] = column
	level.rooms = rooms

	# Create tiles based on wether tile is solid or not
	for x in level_size.x:
		for y in level_size.y:
			var solid = mask[x][y >> 3] >> (y % 8) & 1
			# print(solid)
			if solid:
				level.world_tiles[x][y] = 1
			else:
				level.world_tiles[x][y] = 0

	return level
@warning_ignore_restore("integer_division")


static func get_branching(world_seed:int, position:PackedInt32Array) -> Array[LevelDisplayData]:
	var base_seed := SeedUtil.combine(world_seed, hash(position))
	var rand := SeedUtil.rng_for(base_seed)
	var branch_count := rand.randi_range(2, 5)
	var branches:Array[LevelDisplayData]
	for b in branch_count:
		var branch = LevelDisplayData.new()
		branches.append(branch)

	return branches
