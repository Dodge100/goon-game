class_name InventoryEntry
extends Resource

@export var item: ItemData
@export var amount: int = 1


func _init(p_item: ItemData = null, p_amount: int = 1) -> void:
	item = p_item
	amount = p_amount


func is_empty() -> bool:
	return item == null or amount <= 0


func can_merge_with(other_item: ItemData) -> bool:
	if is_empty() or other_item == null:
		return false
	return item.is_stackable_with(other_item) and amount < item.stack_size


func merge(amount_to_add: int) -> int:
	if is_empty():
		push_error("InventoryEntry.merge called on an empty entry.")
		return amount_to_add
	if amount_to_add <= 0:
		return amount_to_add
	var space: int = item.stack_size - amount
	var taken: int = mini(space, amount_to_add)
	amount += taken
	return amount_to_add - taken


func split(amount_to_take: int) -> InventoryEntry:
	if amount_to_take <= 0 or amount_to_take > amount:
		push_error("InventoryEntry.split: take %d from stack of %d." % [amount_to_take, amount])
		return null
	amount -= amount_to_take
	return InventoryEntry.new(item, amount_to_take)
