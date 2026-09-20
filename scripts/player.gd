class_name Player
extends CharacterBody2D

@export var max_speed: float = 50.0
@export var acceleration: float = 400.0
@export var friction: float = 500.0
@export var inventory: Inventory


func _ready() -> void:
	if inventory == null:
		inventory = Inventory.new()


func pickup_item(item: ItemData, amount: int = 1) -> int:
	if inventory == null:
		push_error("Player.pickup_item called with no inventory.")
		return amount
	return inventory.add_item(item, amount)


func _physics_process(delta: float) -> void:
	var input_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_direction != Vector2.ZERO:
		velocity = velocity.move_toward(input_direction * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()
