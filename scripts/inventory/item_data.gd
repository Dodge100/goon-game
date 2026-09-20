class_name ItemData
extends Resource

@export var id: StringName
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export_range(1, 99) var stack_size: int = 99


func _init(p_id: StringName = &"", p_display_name: String = "", p_stack_size: int = 99) -> void:
	id = p_id
	display_name = p_display_name
	stack_size = maxi(1, p_stack_size)


func is_valid() -> bool:
	return not String(id).is_empty() and stack_size >= 1


func is_stackable_with(other: ItemData) -> bool:
	if other == null:
		return false
	if stack_size <= 1 or other.stack_size <= 1:
		return false
	return id == other.id
