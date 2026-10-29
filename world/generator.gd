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

	# find and create doors
	var astar := AStar2D.new()

	var neighbour_tree := get_neighbour_tree(rooms, 1, 3)

	for r in rooms.size():
		astar.add_point(r, rooms[r].position)

	for r in neighbour_tree.size():
		astar.add_point(r, rooms[r].position)
		for n in neighbour_tree[r].size():
			astar.connect_points(r, neighbour_tree[r][n])
			# astar.set_point_weight_scale()

	var door_tree:Array[PackedInt32Array]
	door_tree.resize(rooms.size())

	for s in 10:
		var from := rand.randi_range(0, rooms.size() - 1)
		if s > 0:
			while door_tree[from].is_empty():
				from = rand.randi_range(0, rooms.size() - 1)
		var to := rand.randi_range(0, rooms.size() - 1)
		var path := astar.get_id_path(from, to)
		for r in path.size():
			if r > 0:
				if door_tree[path[r]].find(path[r - 1]) == -1:
					door_tree[path[r]].append(path[r - 1])
			if r < path.size() - 1:
				if door_tree[path[r]].find(path[r + 1]) == -1:
					door_tree[path[r]].append(path[r + 1])

	# Create mask of solid or not
	var y_bytes := ceili(level_size.y / 8.0)
	var mask: Array[PackedByteArray] = []
	for x in level_size.x:
		var column := PackedByteArray()
		column.resize(y_bytes)
		column.fill(0xFF)
		mask.append(column)

	# var door_already_connected:Array[PackedInt32Array]
	# door_already_connected.resize(rooms.size())

	for r in rooms.size():
		# carve rooms, skip if has no doors
		if !door_tree[r].is_empty():
			for x in range(rooms[r].position.x, rooms[r].end.x):
				var column := mask[x]
				for y in range(rooms[r].position.y, rooms[r].end.y):
					column[y >> 3] &= ~(1 << (y & 7))
				mask[x] = column

		# carve doors
		var connected := door_tree[r]
		for d in connected.size():
			var other := connected[d]
			if other < r:
				continue  # carve each pair once
			var a := rooms[r]
			var b := rooms[other]
			var y_overlap := mini(a.end.y, b.end.y) - maxi(a.position.y, b.position.y)
			var x_overlap := mini(a.end.x, b.end.x) - maxi(a.position.x, b.position.x)
			var pos: Vector2i
			if y_overlap > x_overlap:
				# side by side: vertical wall, door varies along Y
				pos.y = maxi(a.position.y, b.position.y) + rand.randi_range(1, y_overlap - 2)
				pos.x = a.end.x if b.position.x > a.position.x else a.position.x - 1
			else:
			# stacked: horizontal wall, door varies along X
				pos.x = maxi(a.position.x, b.position.x) + rand.randi_range(1, x_overlap - 2)
				pos.y = a.end.y if b.position.y > a.position.y else a.position.y - 1
			var column := mask[pos.x]
			column[pos.y >> 3] &= ~(1 << (pos.y & 7))
			mask[pos.x] = column

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

static func get_neighbour_tree(rooms:Array[Rect2i], max_gap:int, min_overlap:int) -> Array[PackedInt32Array]:
	var neighbours:Array[PackedInt32Array]
	neighbours.resize(rooms.size())

	for r in rooms.size():
		for n in rooms.size():
			if r == n: continue
			if is_neighbour(rooms[r], rooms[n], 1, 3):
				neighbours[r].append(n)

	return neighbours

# static func sample_random_room(level_size:Vector2i, rooms:Array[Rect2i], rand:RandomNumberGenerator) -> int:
# 	pass

static func is_neighbour(a:Rect2i, b:Rect2i, max_gap:int, min_overlap:int) -> bool:
	var y_overlap := mini(a.end.y, b.end.y) - maxi(a.position.y, b.position.y)
	var x_overlap := mini(a.end.x, b.end.x) - maxi(a.position.x, b.position.x)
	if y_overlap >= min_overlap:
		if abs(x_overlap) <= max_gap:
			return true
	if x_overlap >= min_overlap:
		if abs(y_overlap) <= max_gap:
			return true
	return false



static func get_branching(world_seed:int, position:PackedInt32Array) -> Array[LevelDisplayData]:
	var base_seed := SeedUtil.combine(world_seed, hash(position))
	var rand := SeedUtil.rng_for(base_seed)
	var branch_count := rand.randi_range(2, 5)
	var branches:Array[LevelDisplayData]
	for b in branch_count:
		var branch = LevelDisplayData.new()
		branches.append(branch)

	return branches
