class_name InventoryUI
extends Control

const SLOT_SCENE: PackedScene = preload("res://scenes/inventory_slot_ui.tscn")

@export var columns: int = 6
@export var player_path: NodePath

@onready var _grid: GridContainer = %SlotGrid

var _inventory: Inventory
var _slot_views: Array[InventorySlotUI] = []
var _selected_index: int = -1


func _ready() -> void:
	_grid.columns = columns
	_build_slots()
	_resolve_player_inventory()
	refresh()
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_inventory"):
		toggle()
		get_viewport().set_input_as_handled()


func bind(target: Inventory) -> void:
	if _inventory != null and _inventory.inventory_changed.is_connected(refresh):
		_inventory.inventory_changed.disconnect(refresh)
	_inventory = target
	if _inventory != null:
		_inventory.inventory_changed.connect(refresh)
		_rebuild_for_size()
	refresh()


func toggle() -> void:
	visible = not visible


func open() -> void:
	show()


func close() -> void:
	hide()
	_selected_index = -1


func refresh() -> void:
	if _slot_views.is_empty():
		return
	if _inventory == null:
		for slot_view in _slot_views:
			slot_view.set_entry(null)
		return
	_rebuild_for_size()
	for index in _slot_views.size():
		_slot_views[index].set_entry(_inventory.get_entry(index))


func _resolve_player_inventory() -> void:
	if player_path.is_empty():
		return
	var player_node := get_node_or_null(player_path)
	if not player_node is Player:
		push_error("InventoryUI: player_path must point to a Player with an `inventory`.")
		return
	bind(player_node.inventory)


func _build_slots() -> void:
	for child in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	_slot_views.clear()
	var count: int = _inventory.size if _inventory != null else Inventory.DEFAULT_SIZE
	for index in count:
		var slot_view := SLOT_SCENE.instantiate() as InventorySlotUI
		slot_view.bind_index(index)
		slot_view.slot_pressed.connect(_on_slot_pressed)
		_grid.add_child(slot_view)
		_slot_views.append(slot_view)


func _rebuild_for_size() -> void:
	if _inventory != null and _inventory.size != _slot_views.size():
		_build_slots()


func _on_slot_pressed(index: int) -> void:
	if _inventory == null:
		return
	if _selected_index == -1:
		_selected_index = index
		return
	if _selected_index == index:
		_selected_index = -1
		return
	_inventory.swap_slots(_selected_index, index)
	_selected_index = -1
