extends Node

@export var tile_library:TileLibrary
@export var item_library:ItemLibrary
@export var projectile_library:ProjectileLibrary
@export var entity_library:EntityLibrary
@export var prop_library:PropLibrary

func _ready() -> void:
	tile_library.initilize()
	item_library.initilize()
	projectile_library.initilize()
	entity_library.initilize()
	prop_library.initilise()
