extends Node2D

@export var attack: Attack

var _can_attack: bool = true
var _cooldown_timer: Timer


func _ready() -> void:
	_cooldown_timer = Timer.new()
	_cooldown_timer.one_shot = true
	_cooldown_timer.timeout.connect(
		func():
			_can_attack = true,
	)
	add_child(_cooldown_timer)

	attack.mount(self)


func _process(delta: float) -> void:
	attack.update(self, delta)

	if Input.is_action_just_pressed("attack"):
		spawn_attack(get_local_mouse_position())


func spawn_attack(direction: Vector2) -> bool:
	_can_attack = false
	_cooldown_timer.start(5)

	var player = get_parent() as Node2D
	attack.execute(player, direction)

	return true
