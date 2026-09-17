extends Camera2D

@export var target: Node2D
@export var interpolation: float = 10.0

func _process(delta: float) -> void:
	if not target:
		return

	global_position = global_position.lerp(target.global_position, interpolation * delta)
