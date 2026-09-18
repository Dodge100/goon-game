class_name HealthComponent
extends Node

signal damaged(damage: float, new_health: float)
signal died

@export var max_health: float = 10

var health: float = max_health


func take_damage(damage: float):
	health = max(0, health - damage)
	damaged.emit(damage, health)

	if health == 0:
		died.emit()
