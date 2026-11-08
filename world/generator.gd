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

	var FLOOR:int = Global.tile_library.id_str_lookup[&'floor']
	var WALL:int = Global.tile_library.id_str_lookup[&'wall']
	var FLOOR_STUDDED:int = Global.tile_library.id_str_lookup[&'floor_studded']
	var FLOOR_CHECKERED:int = Global.tile_library.id_str_lookup[&'floor_checkered']

	# Create mask of solid or not
	var y_bytes := ceili(level_size.y / 8.0)
	var mask: Array[PackedByteArray] = []
	for x in level_size.x:
		var column := PackedByteArray()
		column.resize(y_bytes)
		column.fill(0xFF)
		mask.append(column)
	level.solid_mask = mask
	for x in level.base_tiles.size():
		level.base_tiles[x].fill(WALL)
	# carve out rooms and doors and makr mask
	for r in rooms.size():
		if door_tree[r].is_empty(): continue
		for x in range(rooms[r].position.x, rooms[r].end.x):
			var column := mask[x]
			for y in range(rooms[r].position.y, rooms[r].end.y):
				column[y >> 3] &= ~(1 << (y & 7))
				level.base_tiles[x][y] = FLOOR_CHECKERED
			mask[x] = column

		# carve doors
		for d in room_doors[r].size():
			var x:int = room_doors[r][d].x
			var y:int = room_doors[r][d].y
			mask[x][y >> 3] &= ~(1 << (y & 7))
			level.base_tiles[x][y] = FLOOR_STUDDED

#
# 	# Create the walls of the map based on the solid or not mask
# 	for x in level_size.x:
# 		for y in level_size.y:
# 			var solid = mask[x][y >> 3] >> (y % 8) & 1
# 			# print(solid)
# 			if solid:
# 				level.base_tiles[x][y] = 1
# 			else:
# 				level.base_tiles[x][y] = 0


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
		elif mini(room.size.x, room.size.y) >= 10:
			# print("LARGE")
			_gen_large_room(room, room_doors[r], level, rand)
		elif mini(room.size.x, room.size.y) >= 6:
			# print("MEDIUM")
			_gen_medium_room(room, room_doors[r], level, rand)
		else:
			# print("REGULAR")
			_gen_normal_room(room, room_doors[r], level, rand)
	return level
@warning_ignore_restore("integer_division")

# AWDKJAWLDKJWAODJ ROOM GENERATION

static func _gen_spawn_room(room:Rect2i, doors: Array, level:LevelData, rand:RandomNumberGenerator):
	# level.teleport_thing_pos = Vector2(
	# 	rand.randf_range(1, room.size.x - 1),
	# 	rand.randf_range(1, room.size.x - 1)
	# ) + Vector2(room.position)
	var OFFICE_DESK:int = Global.tile_library.id_str_lookup[&'office_desk']
	level.teleport_thing_pos = Vector2(room.position) + Vector2(1, 1)
	level.spawn_pos = level.teleport_thing_pos

	level.props.append(&"cache_box")
	level.prop_positions.append(Vector2(room.end) - Vector2(2, 2))
	var prop_data:CacheBoxDataResource = CacheBoxDataResource.new()
	prop_data.stored_item = "heal"
	level.prop_data[level.props.size() - 1] = prop_data

	var x := room.position.x + 3
	var y := room.position.y + 3
	level.mid_tiles[x][y] = OFFICE_DESK

static func _gen_spawn_adj_room(room:Rect2i, doors: Array, level:LevelData, rand:RandomNumberGenerator):
	var FLOOR:int = Global.tile_library.id_str_lookup[&'floor']
	var WALL:int = Global.tile_library.id_str_lookup[&'wall']
	var FLOOR_STUDDED:int = Global.tile_library.id_str_lookup[&'floor_studded']
	var FLOOR_CHECKERED:int = Global.tile_library.id_str_lookup[&'floor_checkered']

	# for d in doors.size():
	# 	var pos:Vector2i = doors[d] - room.position
	# 	print(pos)
	for x in range(room.position.x + 1, room.end.x - 1):
		for y in range(room.position.y + 1, room.end.y - 1):
			level.base_tiles[x][y] = WALL
			level.solid_mask[x][y >> 3] &= ~(1 << (y & 7))

	if mini(room.size.x, room.size.y) >= 6:
		for x in range(room.position.x + 2, room.end.x - 2):
			for y in range(room.position.y + 2, room.end.y - 2):
				level.base_tiles[x][y] = FLOOR
				level.solid_mask[x][y >> 3] &= (1 << (y & 7))

		level.base_tiles[room.position.x + 1][room.position.y + 3] = FLOOR_STUDDED

const DESK_SIZE := Vector2i(2, 3) # desk tile size, prolly upgrade to a better system for large tiles instead of hard coded stuff
const DESK_AISLE := 1  # free rows below each desk row
const DESK_SKIP_CHANCE := 0.08  # chance a desk slot is left empty

@warning_ignore_start("integer_division")
static func _gen_large_room(room: Rect2i, doors: Array, level: LevelData, rand: RandomNumberGenerator) -> void:
	var type := rand.randi_range(0, 1)
	if type <= 0:	# 'natural' layout (its pretty bad and not natural at all, looks like the backrooms ig) needs a bit of love in the future
		var OFFICE_DESK: int = Global.tile_library.id_str_lookup[&'office_desk']
		var WALL: int = Global.tile_library.id_str_lookup[&'wall']

		var path := find_path_all_doors(room, doors)

		var size := room.size
		var row_pitch := DESK_SIZE.y + DESK_AISLE

		var cols := (size.x - 2) / DESK_SIZE.x
		var x_slack := (size.x - 2) - cols * DESK_SIZE.x
		var rows := (size.y - 1) / row_pitch
		var y_slack := (size.y - 1) - rows * row_pitch
		if cols < 1 or rows < 1:
			return  # room too small

		var x0 := 1 + rand.randi_range(0, x_slack)
		var y0 := 1 + rand.randi_range(0, y_slack)

		for row in rows:
			var y := y0 + row * row_pitch
			for col in cols:
				var x := x0 + col * DESK_SIZE.x
				if rand.randf() < DESK_SKIP_CHANCE:
					continue
				if _desk_hits_path(path, Vector2i(x, y)):
					continue
				level.mid_tiles[x + room.position.x][y + room.position.y] = OFFICE_DESK

		var band_height := rows * row_pitch
		var block_x_end := x0 + cols * DESK_SIZE.x
		for lx in size.x:
			var on_x_edge := lx == 0 or lx == size.x - 1
			for ly in size.y:
				if on_x_edge or ly == 0 or ly == size.y - 1:
					continue
				if not path.is_empty() and path[lx][ly]:
					continue
				var rel_y := ly - y0
				if rel_y >= 0 and rel_y < band_height:
					if rel_y % row_pitch >= DESK_SIZE.y:
						continue
					if lx >= x0 and lx < block_x_end:
						continue
				level.base_tiles[room.position.x + lx][room.position.y + ly] = WALL

	elif type <= 1:  # 'rigid' desk generation
		var OFFICE_DESK: int = Global.tile_library.id_str_lookup[&'office_desk']
		var columns := (room.size.x - 2) / 2
		var rows := (room.size.y - 2) / 4
		var x_offset := ((room.size.x - 2) % columns) / 2
		var y_offset := ((room.size.y - 2) % rows) / 2

		for cx in columns:
			var x := cx * 2 + 1 + room.position.x + x_offset
			for ry in rows:
				var y := ry * 4 + 1 + room.position.y + y_offset
				level.mid_tiles[x][y] = OFFICE_DESK
@warning_ignore_restore("integer_division")

# helper for large room gen
static func _desk_hits_path(path: Array[Array], local: Vector2i) -> bool:
	if path.is_empty():
		return false
	for dx in DESK_SIZE.x:
		for dy in DESK_SIZE.y:
			if path[local.x + dx][local.y + dy]:
				return true
	return false

static func _gen_medium_room(room:Rect2i, doors: Array, level:LevelData, rand:RandomNumberGenerator):
	var WALL:int = Global.tile_library.id_str_lookup[&'wall']
	var type := rand.randi_range(0, 10)
	if type <= 1:	# 'library' type room
		var div: bool	# true is vertical div else horizontal div
		if room.size.x > room.size.y:
			div = true
		else:
			div = false

		var path := find_path_all_doors(room, doors)

		# door pathing edge cases
		if doors.size() == 1:
			if doors[0].x < room.position.x or doors[0].x >= room.end.x:
				div = true
			else:
				div = false
		else:
			# pass vert and horizontal line test to test for continuity whether there is a path that passes
			# through the whole room either horizontaly or vertically
			var row:Array[bool]
			row.resize(room.size.y)
			row.fill(false)
			var collumn:Array[bool]
			collumn.resize(room.size.x)
			collumn.fill(false)
			for cx in path.size():
				for ry in path[cx].size():
					if path[cx][ry]:
						collumn[cx] = true
						row[ry] = true

			var hori := collumn.has(false)	# hotizontally not continous dosent pass vertical line test
			var vert := row.has(false)		# vertically not continous

			if hori and vert:
				# likely path is 'L' shape, cannot generate room type with orphaned area
				# so make a path that links the divs
				if div:	# vertical div so run horizontal path up at up and down just to make sure
					_fill_row(path, 0, 0, path[0].size() - 1)
					_fill_row(path, path[0].size() - 1, 0, path.size() - 1)
				else:
					_fill_col(path, 0, 0, path[0].size() - 1)
					_fill_col(path, path.size() - 1, 0, path[0].size() - 1)
			elif hori:	# if horizontaly not continous div horizontaly
				div = false
			elif vert:
				div = true

		if div:
			# wide room, div vertically
			for cx in room.size.x:
				if (cx + 1) % 2 != 0: continue
				_fill_col(path, cx, 0, path[cx].size() - 1)
		else:
			for ry in room.size.y:
				if (ry + 1) % 2 != 0: continue
				_fill_row(path, ry, 0, path.size() - 1)

		for cx in path.size():
			for ry in path[cx].size():
				if !path[cx][ry]:
					var x := cx + room.position.x
					var y := ry + room.position.y
					level.base_tiles[x][y] = WALL



static func _gen_normal_room(room:Rect2i, doors: Array, level:LevelData, rand:RandomNumberGenerator):
	var WALL:int = Global.tile_library.id_str_lookup[&'wall']
	var type := rand.randi_range(0, 10)
	if type <= 2:	# corridore rooms
		var path := find_path_all_doors(room, doors)
		for cx in path.size():
			for ry in path[cx].size():
				if !path[cx][ry]:
					var x := cx + room.position.x
					var y := ry + room.position.y
					level.base_tiles[x][y] = WALL


# OTHER STUFF

## gets the path that reaches all doors in a room (not optimal but like she'll be right)
## doors are worldspace vec2i
static func find_path_all_doors(room: Rect2i, doors: Array) -> Array[Array]:
	var size := room.size
	var ins: Array[Vector2i] = []   # tile inside the room next to each door
	var dirs: Array[Vector2i] = []  # direction pointing into the room from each door
	var hori: Array[int] = []       # horizontal L/R doors
	var vert: Array[int] = []       # vert doors

	for door in doors:
		var world_pos: Vector2i = door
		var entry := _door_entry(world_pos - room.position, size)
		if entry.is_empty():
			continue
		if entry[1].x != 0:
			hori.append(ins.size())
		else:
			vert.append(ins.size())
		ins.append(entry[0])
		dirs.append(entry[1])

	if ins.is_empty():
		return []

	var path: Array[Array] = []
	for x in size.x:
		var column: Array[bool] = []
		column.resize(size.y)
		column.fill(false)
		path.append(column)

	# if only one door it does straight line across the room
	if ins.size() == 1:
		if dirs[0].x != 0:
			_fill_row(path, ins[0].y, 0, size.x - 1)
		else:
			_fill_col(path, ins[0].x, 0, size.y - 1)
		return path

	# gen first path that joings the first two doors
	var ry: int	# row y
	var cx: int	# collumn x if later paths dont hit used, extend one of these and join to it
	var used: Array[int]

	if !hori.is_empty() and !vert.is_empty():
		# both vert and hoizonal doors, generate 'L' shape
		var h := hori[0]
		var v := vert[0]
		ry = ins[h].y
		cx = ins[v].x
		_fill_row(path, ry, ins[h].x, cx)
		_fill_col(path, cx, ry, ins[v].y)
		used = [h, v]
	elif hori.is_empty():
		# only vert
		var a := vert[0]
		var b := vert[1]
		ry = ins[a].y
		cx = ins[b].x
		_fill_row(path, ry, ins[a].x, cx)
		_fill_col(path, cx, ry, ins[b].y)
		used = [a, b]
	else:
		# only horizontal
		var a := hori[0]
		var b := hori[1]
		cx = ins[a].x
		ry = ins[b].y
		_fill_col(path, cx, ins[a].y, ry)
		_fill_row(path, ry, cx, ins[b].x)
		used = [a, b]

	# extent remaning doors to existing path
	for d in ins.size():
		if used.has(d):
			continue
		if _extend_to_path(path, ins[d], dirs[d], size):
			continue
		if dirs[d].x != 0:
			# horizontal door run to extended ry
			_fill_col(path, cx, ins[d].y, ry)
			_fill_row(path, ins[d].y, ins[d].x, cx)
		else:
			# vertical door run to extended cx
			_fill_row(path, ry, ins[d].x, cx)
			_fill_col(path, ins[d].x, ins[d].y, ry)

	return path

# returns [inside_tile, inward_direction] if door isnt touching room []
static func _door_entry(local: Vector2i, size: Vector2i) -> Array[Vector2i]:
	if local.y >= 0 and local.y < size.y:
		if local.x < 0:
			return [Vector2i(0, local.y), Vector2i.RIGHT]
		if local.x >= size.x:
			return [Vector2i(size.x - 1, local.y), Vector2i.LEFT]
	if local.x >= 0 and local.x < size.x:
		if local.y < 0:
			return [Vector2i(local.x, 0), Vector2i.DOWN]
		if local.y >= size.y:
			return [Vector2i(local.x, size.y - 1), Vector2i.UP]
	return []

# walks from from with dir if it hits anythign it fills the path else dosent do anything and retuns false
static func _extend_to_path(path: Array[Array], from: Vector2i, dir: Vector2i, size: Vector2i) -> bool:
	var run: Array[Vector2i] = []
	var p := from
	while p.x >= 0 and p.y >= 0 and p.x < size.x and p.y < size.y:
		if path[p.x][p.y]:
			for c in run:
				path[c.x][c.y] = true
			return true
		run.append(p)
		p += dir
	return false

static func _fill_row(path: Array[Array], y: int, x0: int, x1: int, value = true) -> void:
	for x in range(mini(x0, x1), maxi(x0, x1) + 1):
		path[x][y] = value

static func _fill_col(path: Array[Array], x: int, y0: int, y1: int, value = true) -> void:
	for y in range(mini(y0, y1), maxi(y0, y1) + 1):
		path[x][y] = value





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
