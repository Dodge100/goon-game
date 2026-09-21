extends Node2D

# noise
const debug := true
# where the resulting structure will be
@onready var base: TileMapLayer = $base
# array of TileMapLayers
var maps = []
# corridor tiles between rooms
# must be >=1 if padding is 1 to avoid rooms colliding!!
const gap := 2
# minimum empty tiles between rooms
const padding :=1
# doors are corridor tiles that get connected
# this is for doors that are not taken yet
# follows {"cell": Vector2i, "dir": Vector2i} where dir points away
var open_doors: Array[Dictionary] = []
# cache :wires:
var _door_cache: Dictionary = {}

func _ready() -> void:
	for maplayer in get_children():
		if maplayer is TileMapLayer and maplayer != base:
			maps.append(maplayer)
			maplayer.visible = false # only leave $base visible
	if debug:
		for map in maps.size():
			print(map, ": ", maps[map].get_used_cells().size(), find_entrace_exits(maps[map]))
	compose_rooms()
	return

func _cell_to_cell(from: TileMapLayer, cell: Vector2i, to: TileMapLayer) -> Vector2i:
	var world := from.to_global(from.map_to_local(cell))
	return to.local_to_map(to.to_local(world))

func compose_rooms() -> void:
	base.clear()
	open_doors.clear()

	# clone so that we're not modifying `maps`
	var pool: Array[TileMapLayer] = maps.duplicate()
	pool.shuffle()
	if pool.is_empty():
		if debug:
			print("!!pool empty!!")
		return

	var r1: TileMapLayer = pool.pop_back()
	_place(r1, -r1.get_used_rect().get_center())
	
	while not pool.is_empty():
		if not _try_connect(pool):
			print("!!%d rooms cant attach!!" % pool.size())
			break

# bruteforces all combinations until it finds a legal one
func _try_connect(pool: Array[TileMapLayer]) -> bool:
	open_doors.shuffle()
	
	for door_index in open_doors.size():
		var a: Dictionary = open_doors[door_index]
		var path: Array[Vector2i] = _path_cells(a.cell, a.dir)
		if not _path_clear(path):
			continue
			
		var exempt: Array[Vector2i] = path.duplicate()
		exempt.append(a.cell)
		
		for room_index in pool.size():
			var room: TileMapLayer = pool[room_index]
			var candidates: Array[Dictionary] = _doors_of(room).duplicate()
			candidates.shuffle()
			
			for b in candidates:
				if b.dir != -a.dir:
					continue
					
				# AI: stupid math aaaaa
				# Solve for the offset that lands door `b` at the far end of the gap.
				var offset: Vector2i = a.cell + a.dir * (gap + 1) - b.cell
				if not _fits(room, offset, exempt):
					continue
 
				_place(room, offset, [b.cell + offset] as Array[Vector2i])
				_carve(path, a.cell)
				open_doors.remove_at(door_index)
				pool.remove_at(room_index)
				return true
	return false

# copies every `room`'s cell into $base with `offset` and opens its doors
# (except for consumed)
func _place(room: TileMapLayer, offset: Vector2i, consumed: Array[Vector2i] = []) -> void:
	for cell in room.get_used_cells():
		base.set_cell(
			cell+offset, # coords
			room.get_cell_source_id(cell), # source_id
			room.get_cell_atlas_coords(cell), # atlas_coords
		)
		
	for door in _doors_of(room):
		var placed: Vector2i = door.cell + offset
		if placed in consumed:
			continue
		open_doors.append({"cell": placed, "dir": door.dir})

# fills the gap between two doors
func _carve(path: Array[Vector2i], template: Vector2i) -> void:
	var source := base.get_cell_source_id(template)
	var atlas := base.get_cell_atlas_coords(template)
	for cell in path:
		base.set_cell(cell, source, atlas)

# find all doors on a map
func _doors_of(map: TileMapLayer) -> Array[Dictionary]:
	if _door_cache.has(map):
		return _door_cache[map]
 
	var out: Array[Dictionary] = []
	for cell in map.get_used_cells():
		var td := map.get_cell_tile_data(cell)
		if td and td.get_custom_data("corridor"):
			var dir := _door_dir(map, cell)
			if dir == Vector2i.ZERO:
				print("%s: door at %s has no clear outward direction" % [map.name, cell])
				continue
			out.append({ "cell": cell, "dir": dir })
 
	_door_cache[map] = out
	return out

# whats its direction?
func _door_dir(map: TileMapLayer, cell: Vector2i) -> Vector2i:
	for neighbour in map.get_surrounding_cells(cell):
		var dir: Vector2i = cell - neighbour
		if map.get_cell_source_id(neighbour) != -1 \
		and map.get_cell_source_id(cell + dir) == -1:
			return dir
	return Vector2i.ZERO

func _path_cells(from: Vector2i, dir: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for i in range(1, gap + 1):
		out.append(from + dir * i)
	return out
 
# returns true if the room doesnt collide with anything on $base
# `exempt` is ignored because thats what is being attached
func _fits(room: TileMapLayer, offset: Vector2i, exempt: Array[Vector2i]) -> bool:
	var skip := {}
	for cell in exempt:
		skip[cell] = true
 
	for cell in room.get_used_cells():
		var target: Vector2i = cell + offset
		for dy in range(-padding, padding + 1):
			for dx in range(-padding, padding + 1):
				var probe := target + Vector2i(dx, dy)
				if skip.has(probe):
					continue
				if base.get_cell_source_id(probe) != -1:
					return false
	return true

func _path_clear(path: Array[Vector2i]) -> bool:
	for cell in path:
		if base.get_cell_source_id(cell) != -1:
			return false
	return true


func find_entrace_exits(_map: TileMapLayer) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for cell in _map.get_used_cells():
		var td := _map.get_cell_tile_data(cell)
		# each room has a `corridor` Custom Data Layer
		# -> these are at the end of each corridor so
		# that the code can connect them :thumbup:
		if td and td.get_custom_data("corridor"):
			out.append(cell)
	return out

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
