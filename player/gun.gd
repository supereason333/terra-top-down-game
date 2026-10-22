extends Marker2D

@onready var cooldown_timer:Timer = $CooldownTimer

var world:World

var firing := false

func _ready() -> void:
	world = GameMngr.get_world()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and cooldown_timer.is_stopped():
				fire()
				cooldown_timer.start()

func fire():
	var proj:LinearProjectile = Projectiles.BASIC_BULLET.instantiate()
	proj.position = global_position
	proj.rotation = global_rotation
	world.register_projectile(proj)
