extends Node2D

# array of TileMapLayers
var maps = []
func _ready() -> void:
	for maplayer in get_children():
		if maplayer is TileMapLayer:
			maps.append(maplayer)
	for map in maps.size():
		print(map, ": ", maps[map].get_used_cells().size(), find_entrace_exits(maps[map]))
	return

func find_entrace_exits(_map: TileMapLayer) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for cell in _map.get_used_cells():
		var td := _map.get_cell_tile_data(cell)
		if td and td.get_custom_data("corridor"):
			out.append(cell)
	return out

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
