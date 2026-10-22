extends LinearProjectile


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is TileMapLayer: queue_free()
