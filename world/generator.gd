class_name WorldGenerator

const MAX_SIZE_TILES = 100
const MIN_SIZE_TILES = 60

const MIN_ROOM_SIZE = 4
const MAX_ROOM_SIZE = 12

const MIN_ROOM_OVERLAP = 3	# overlap to be considered neighbours
const DOOR_MIN_DIST_FROM_CORNER = 1	# dooes arnt in the corner of rooms. make sure 2x < MIN_ROOM_OVERLAP
const WALL_THICKNESS = 2
const MIN_SPLITTABLE = MIN_ROOM_SIZE * 2 + WALL_THICKNESS

# upgrade thing "plan":
	# remake so data structures come fies: rooms, doors, etc
	# before any tiles need to be placed.
	# either generator writes the tiles
	# or the world builder can do it idk yet

@warning_ignore_start("integer_division")
# static func generate_level(level_seed:int, settings:LevelGeneratorSettings) -> LevelData:
static func generate_level(world_seed:int, level_position:PackedInt32Array) -> LevelData:
	# yes i know this is very unpotimised it gives me more time to display a waiting screen
	# or something idk
	var rand := RandomNumberGenerator.new()
	rand.seed = SeedUtil.combine(world_seed, hash(level_position))
	var level_size:Vector2i = Vector2i(
		rand.randi_range(MIN_SIZE_TILES, MAX_SIZE_TILES),
		rand.randi_range(MIN_SIZE_TILES, MAX_SIZE_TILES)
	)
	var rooms:Array[Rect2i]
	rooms.append(Rect2i(Vector2i(1, 1), level_size - Vector2i(2, 2)))

	# yeah
	var large_rooms:PackedInt32Array = [0]	# too large rooms

	# Divide rooms
	while !large_rooms.is_empty():
		if large_rooms.is_empty(): break
		var i := large_rooms.size() - 1
		var room = rooms[large_rooms[i]]
		var divide := rand.randi_range(MIN_ROOM_SIZE, maxi(room.size.x, room.size.y) - MIN_ROOM_SIZE - WALL_THICKNESS)
		var divided = divide_room(room, divide)
		rooms.append(divided[1])
		rooms[large_rooms[i]] = divided[0]

		if maxi(divided[0].size.x, divided[0].size.y) <= MAX_ROOM_SIZE:
			large_rooms.remove_at(i)
		if maxi(divided[1].size.x, divided[1].size.y) > MAX_ROOM_SIZE:
			large_rooms.append(rooms.size() - 1)

	# find and create doors
	# runs path through randomly and creates the connections
	var astar := AStar2D.new()

	var neighbour_tree := get_neighbour_tree(rooms, WALL_THICKNESS, MIN_ROOM_OVERLAP)

	for r in rooms.size():
		astar.add_point(r, rooms[r].position)

	for r in neighbour_tree.size():
		astar.add_point(r, rooms[r].position)
		for n in neighbour_tree[r].size():
			astar.connect_points(r, neighbour_tree[r][n])
			# astar.set_point_weight_scale()

	var door_tree:Array[PackedInt32Array]
	door_tree.resize(rooms.size())

	var used: Array[int] = [rand.randi_range(0, rooms.size() - 1)]	# rooms that have been walked
	for s in 40:
		var from: int = used[rand.randi_range(0, used.size() - 1)]
		var to := rand.randi_range(0, rooms.size() - 1)
		var path := astar.get_id_path(from, to)
		if path.size() < 2:
			continue  # same room or unreachable
		for r in path.size():
			if r > 0 and door_tree[path[r]].find(path[r - 1]) == -1:
				door_tree[path[r]].append(path[r - 1])
			if r < path.size() - 1 and door_tree[path[r]].find(path[r + 1]) == -1:
				door_tree[path[r]].append(path[r + 1])
			if not used.has(path[r]):
				used.append(path[r])

	# FINISHED GENERATING ROOMS AND CONNECTING DOORS
	# filer out to the real used rooms

	# oh how i wished there was a struct please god give me a struct
	# godot rust bindings look pretty attractive right now
	# DOOr generation
	var room_doors: Dictionary[int, Array] = {}  # int -> Array[Array[Vector2i]]
	for r in rooms.size():
		if door_tree[r].is_empty():
			continue
		var room := rooms[r]
		for other in door_tree[r]:
			if other < r:
				continue  # this pair is handled when the lower-indexed room is visited

			var doors := generate_doors(room, rooms[other], rand)
			if doors.is_empty():
				continue

			if not room_doors.has(r):
				room_doors[r] = []
			room_doors[r].append(doors[0])

			if not room_doors.has(other):
				room_doors[other] = []
			room_doors[other].append(doors[1])

	# got the real rooms, generate room contents and place tiles next
	var level = LevelData.new(level_size)

	# Create mask of solid or not
	var y_bytes := ceili(level_size.y / 8.0)
	var mask: Array[PackedByteArray] = []
	for x in level_size.x:
		var column := PackedByteArray()
		column.resize(y_bytes)
		column.fill(0xFF)
		mask.append(column)

	# carve out rooms and doors from the mask
	for r in rooms.size():
		if door_tree[r].is_empty(): continue
		for x in range(rooms[r].position.x, rooms[r].end.x):
			var column := mask[x]
			for y in range(rooms[r].position.y, rooms[r].end.y):
				column[y >> 3] &= ~(1 << (y & 7))
			mask[x] = column

		# carve doors
		for d in room_doors[r].size():
			var x:int = room_doors[r][d].x
			var y:int = room_doors[r][d].y
			mask[x][y >> 3] &= ~(1 << (y & 7))



	# Create the walls of the map based on the solid or not mask
	for x in level_size.x:
		for y in level_size.y:
			var solid = mask[x][y >> 3] >> (y % 8) & 1
			# print(solid)
			if solid:
				level.base_tiles[x][y] = 1
			else:
				level.base_tiles[x][y] = 0


	# figure out spawn room, spawn room and surroundings dont have enemies and stuff
	var spawn_room:int = -1
	var best := -1
	var dist:float = INF
	for r in rooms.size():
		if door_tree[r].is_empty(): continue
		if rooms[r].has_point(level_size / 2):
			spawn_room = r
			break
		var new_dist := rooms[r].position.distance_squared_to(level_size / 2)
		if new_dist < dist:
			dist = new_dist
			best = r
	if spawn_room == -1:
		spawn_room = best

	# level.spawn = (used_rooms[spawn_room].position + used_rooms[spawn_room].end) / 2

	for r in rooms.size():
		if door_tree[r].is_empty(): continue
		var room := rooms[r]
		if r == spawn_room:
			# spawnroom
			_gen_spawn_room(room, room_doors[r], level, rand)
		elif door_tree[r].has(spawn_room):
			# adj to spawn room
			_gen_spawn_adj_room(room, room_doors[r], level, rand)
		elif mini(room.size.x, room.size.y) >= 20:
			# large room
			pass
		elif mini(room.size.x, room.size.y) >= 12:
			# medium large room
			pass
		else:
			# regular room
			pass
	return level
@warning_ignore_restore("integer_division")

# AWDKJAWLDKJWAODJ ROOM GENERATION

static func _gen_spawn_room(room:Rect2i, doors: Array, level:LevelData, rand:RandomNumberGenerator):
	level.teleport_thing_pos = Vector2(
		rand.randf_range(1, room.size.x - 1),
		rand.randf_range(1, room.size.x - 1)
	) + Vector2(room.position)
	# level.teleport_thing_pos *= 16
	level.spawn_pos = level.teleport_thing_pos

static func _gen_spawn_adj_room(room:Rect2i, doors: Array, level:LevelData, rand:RandomNumberGenerator):
	for d in doors.size():
		var pos:Vector2i = doors[d] - room.position
		print(pos)

# OTHER STUFF

## generates the pair of doors for rooms a and b, retuirns arr idx 0 for a, 1 for b
## door pos in world coords
## empty arr means error
static func generate_doors(a: Rect2i, b: Rect2i, rand: RandomNumberGenerator) -> Array[Vector2i]:
	var x_overlap := mini(a.end.x, b.end.x) - maxi(a.position.x, b.position.x)
	var y_overlap := mini(a.end.y, b.end.y) - maxi(a.position.y, b.position.y)
	var min_overlap := maxi(MIN_ROOM_OVERLAP, DOOR_MIN_DIST_FROM_CORNER * 2 + 1)

	# side by side
	if y_overlap >= min_overlap and x_overlap < 0 and -x_overlap <= WALL_THICKNESS:
		var y := rand.randi_range(
			maxi(a.position.y, b.position.y) + DOOR_MIN_DIST_FROM_CORNER,
			mini(a.end.y, b.end.y) - DOOR_MIN_DIST_FROM_CORNER - 1)
		if a.position.x < b.position.x:  # a is on the left
			return [Vector2i(a.end.x, y), Vector2i(b.position.x - 1, y)]
		return [Vector2i(a.position.x - 1, y), Vector2i(b.end.x, y)]

	# stacked
	if x_overlap >= min_overlap and y_overlap < 0 and -y_overlap <= WALL_THICKNESS:
		var x := rand.randi_range(
			maxi(a.position.x, b.position.x) + DOOR_MIN_DIST_FROM_CORNER,
			mini(a.end.x, b.end.x) - DOOR_MIN_DIST_FROM_CORNER - 1)
		if a.position.y < b.position.y:  # a is above
			return [Vector2i(x, a.end.y), Vector2i(x, b.position.y - 1)]
		return [Vector2i(x, a.position.y - 1), Vector2i(x, b.end.y)]

	return []

static func divide_room(room:Rect2i, divide:int) -> Array[Rect2i]:
	var new:Rect2i
	if room.size.x > room.size.y:	# slice room verticaly
		new = Rect2i(
			room.position + Vector2i(divide + WALL_THICKNESS, 0),
			Vector2i(room.size.x - divide - WALL_THICKNESS, room.size.y)
		)
		room.size.x = divide
	else:
		new = Rect2i(
			room.position + Vector2i(0, divide + WALL_THICKNESS),
			Vector2i(room.size.x, room.size.y - divide - WALL_THICKNESS)
		)
		room.size.y = divide

	return [room, new]

static func get_neighbour_tree(rooms:Array[Rect2i], max_gap:int, min_overlap:int) -> Array[PackedInt32Array]:
	var neighbours:Array[PackedInt32Array]
	neighbours.resize(rooms.size())

	for r in rooms.size():
		for n in rooms.size():
			if r == n: continue
			if is_neighbour(rooms[r], rooms[n], max_gap, min_overlap):
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
