extends Node

@export var tile_library:TileLibrary
@export var item_library:ItemLibrary
@export var projectile_library:ProjectileLibrary

func _ready() -> void:
	tile_library.initilize()
	item_library.initilize()
	projectile_library.initilize()
