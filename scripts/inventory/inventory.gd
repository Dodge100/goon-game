class_name Inventory
extends Resource

signal inventory_changed

const DEFAULT_SIZE: int = 30

@export var size: int = DEFAULT_SIZE

var slots: Array[InventoryEntry] = []


func _init(initial_size: int = DEFAULT_SIZE) -> void:
	size = maxi(1, initial_size)
	_ensure_capacity()


func _ensure_capacity() -> void:
	size = maxi(1, size)
	if slots.size() != size:
		slots.resize(size)


func is_valid_index(index: int) -> bool:
	return index >= 0 and index < size


func get_entry(index: int) -> InventoryEntry:
	if not is_valid_index(index):
		push_error("Inventory.get_entry: index %d out of bounds (size %d)." % [index, size])
		return null
	return slots[index]


func count_of(item: ItemData) -> int:
	if item == null:
		return 0
	var total: int = 0
	for entry in slots:
		if entry == null or entry.is_empty():
			continue
		if entry.item.id == item.id:
			total += entry.amount
	return total


func has_space_for(item: ItemData, amount: int = 1) -> bool:
	if item == null or amount <= 0:
		return false
	var remaining: int = amount
	for entry in slots:
		if entry == null or entry.is_empty():
			remaining -= item.stack_size
		elif entry.can_merge_with(item):
			remaining -= item.stack_size - entry.amount
		if remaining <= 0:
			return true
	return false


func add_item(item: ItemData, amount: int = 1) -> int:
	if item == null:
		push_error("Inventory.add_item called with null item.")
		return amount
	if amount <= 0:
		return 0
	var remaining: int = amount
	remaining = _merge_into_existing(item, remaining)
	if remaining > 0:
		remaining = _fill_empty_slots(item, remaining)
	inventory_changed.emit()
	return remaining


func remove_at(index: int, amount: int = 1) -> InventoryEntry:
	if not is_valid_index(index):
		push_error("Inventory.remove_at: index %d out of bounds (size %d)." % [index, size])
		return null
	if amount <= 0:
		push_error("Inventory.remove_at: amount must be positive.")
		return null
	var entry: InventoryEntry = slots[index]
	if entry == null or entry.is_empty():
		return null
	var taken: InventoryEntry = entry.split(mini(amount, entry.amount))
	if entry.is_empty():
		slots[index] = null
	inventory_changed.emit()
	return taken


func swap_slots(first: int, second: int) -> void:
	if not is_valid_index(first) or not is_valid_index(second):
		push_error("Inventory.swap_slots: index out of bounds (%d, %d)." % [first, second])
		return
	if first == second:
		return
	var held: InventoryEntry = slots[first]
	slots[first] = slots[second]
	slots[second] = held
	inventory_changed.emit()


func clear() -> void:
	slots.fill(null)
	inventory_changed.emit()


func _merge_into_existing(item: ItemData, amount: int) -> int:
	var remaining: int = amount
	for entry in slots:
		if remaining <= 0:
			break
		if entry != null and entry.can_merge_with(item):
			remaining = entry.merge(remaining)
	return remaining


func _fill_empty_slots(item: ItemData, amount: int) -> int:
	var remaining: int = amount
	for index in size:
		if remaining <= 0:
			break
		if slots[index] == null or slots[index].is_empty():
			var placed: int = mini(item.stack_size, remaining)
			slots[index] = InventoryEntry.new(item, placed)
			remaining -= placed
	return remaining
