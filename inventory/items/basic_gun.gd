extends Item2D

@onready var cooldown_timer:Timer = $CooldownTimer
@onready var shoot:Marker2D = $Shoot
var world:World

var firing := false

func _ready() -> void:
	world = GameMngr.get_world()

func fire():
	var proj:LinearProjectile = Projectiles.BASIC_BULLET.instantiate()
	proj.position = shoot.global_position
	proj.rotation = shoot.global_rotation
	world.register_projectile(proj)

func _use():
	if cooldown_timer.is_stopped():
		fire()
		cooldown_timer.start()
