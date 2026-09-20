class_name InventorySlotUI
extends PanelContainer

signal slot_pressed(slot_index: int)

const EMPTY_MODULATE := Color(1, 1, 1, 0.35)

var slot_index: int = -1

@onready var icon_rect: TextureRect = %IconRect
@onready var count_label: Label = %CountLabel

var _entry: InventoryEntry


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	focus_mode = FOCUS_ALL
	_clear_visuals()


func bind_index(index: int) -> void:
	slot_index = index


func set_entry(entry: InventoryEntry) -> void:
	_entry = entry
	if _entry == null or _entry.is_empty():
		_clear_visuals()
		return
	if _entry.item.icon != null:
		icon_rect.texture = _entry.item.icon
		icon_rect.modulate = Color.WHITE
	else:
		icon_rect.texture = null
		icon_rect.modulate = EMPTY_MODULATE
	if _entry.amount > 1:
		count_label.text = str(_entry.amount)
		count_label.show()
	else:
		count_label.hide()
	tooltip_text = _entry.item.display_name


func _clear_visuals() -> void:
	icon_rect.texture = null
	icon_rect.modulate = EMPTY_MODULATE
	count_label.hide()
	tooltip_text = ""


func _gui_input(event: InputEvent) -> void:
	var click := event as InputEventMouseButton
	if click == null:
		return
	if click.button_index != MOUSE_BUTTON_LEFT or not click.pressed:
		return
	slot_pressed.emit(slot_index)
	accept_event()
