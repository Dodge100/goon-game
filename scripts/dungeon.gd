extends Node2D

# array of TileMapLayers
var maps = []
func _ready() -> void:
	for maplayer in get_children():
		if maplayer is TileMapLayer:
			maps.append(maplayer)
	for map in maps.size():
		print(map, ": ", maps[map].get_used_cells())
	return
# test commit sdfsdf

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
