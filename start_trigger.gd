extends Area2D

@onready var spawner:Node = $"../GameSpawner"

func _on_body_entered(body:Node2D) -> void:
	if body is Player:
		spawner.start()
		queue_free()
