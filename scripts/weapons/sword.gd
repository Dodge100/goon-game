class_name SwordAttack
extends Attack

@export var texture: Texture2D

var _sprite: Sprite2D


func mount(player: Node2D) -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = texture
	player.add_child(_sprite)


func unmount(player: Node2D) -> void:
	if _sprite and is_instance_valid(_sprite):
		_sprite.queue_free()


func execute(player: Node2D, target_direction: Vector2) -> void:
	print("meow")


func update(player: Node2D, _delta: float) -> void:
	if not _sprite:
		return
	var dir = (player.get_global_mouse_position() - player.global_position).normalized()
	_sprite.position = dir * 16
	_sprite.rotation = dir.angle()
