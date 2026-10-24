extends Item2D

@onready var cooldown_timer:Timer = $CooldownTimer

var world:World

var firing := false

func _ready() -> void:
	world = GameMngr.get_world()

func fire():
	var proj:LinearProjectile = Projectiles.BASIC_BULLET.instantiate()
	proj.position = global_position
	proj.rotation = global_rotation
	world.register_projectile(proj)

func _use():
	if cooldown_timer.is_stopped():
		fire()
		cooldown_timer.start()
