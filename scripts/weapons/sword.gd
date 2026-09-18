class_name SwordAttack
extends Attack

@export var texture: Texture2D

const SWING_ARC: float = PI / 2
const SWING_DURATION: float = 0.18

var _sprite: Sprite2D
var _swing_angle: float = 0.0
var _swing_tween: Tween


func mount(player: Node2D) -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = texture
	_sprite.centered = false
	_sprite.offset = Vector2(0, -texture.get_height())
	player.add_child(_sprite)


func unmount(_player: Node2D) -> void:
	if _swing_tween and _swing_tween.is_valid():
		_swing_tween.kill()
	_swing_angle = 0.0
	if _sprite and is_instance_valid(_sprite):
		_sprite.queue_free()
	_sprite = null


func execute(player: Node2D, direction: Vector2) -> void:
	direction = direction.normalized()
	if _swing_tween and _swing_tween.is_valid():
		_swing_tween.kill()
	_swing_angle = -SWING_ARC * 0.5
	_swing_tween = _sprite.create_tween()
	_swing_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_swing_tween.tween_property(self, "_swing_angle", SWING_ARC * 0.5, SWING_DURATION)


func update(player: Node2D, _delta: float) -> void:
	var aim_direction: Vector2 = player.get_global_mouse_position() - player.global_position
	if aim_direction == Vector2.ZERO:
		return
	var aim_angle: float = aim_direction.angle()
	_sprite.position = aim_direction.normalized() * 2.0
	_sprite.rotation = aim_angle - _swing_angle + PI / 4
