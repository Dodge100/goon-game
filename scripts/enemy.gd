extends CharacterBody2D

@export var speed: float = 20.0
@export var player: Node2D


func _physics_process(delta: float) -> void:
	velocity = (player.position - position).normalized() * speed

	move_and_slide()


func _process(delta: float) -> void:
	($HealthComponent as HealthComponent).take_damage(delta)


func _on_health_component_died() -> void:
	queue_free()
