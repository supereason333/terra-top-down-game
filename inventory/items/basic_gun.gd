extends Item2D

@onready var cooldown_timer:Timer = $CooldownTimer
@onready var shoot:Marker2D = $Shoot
var world:World

var ammo:int = 0
var mag_size:int = 12

var firing := false

func _ready() -> void:
	world = GameMngr.get_world()

func fire():
	var proj:LinearProjectile = Projectiles.BASIC_BULLET.instantiate()
	proj.position = shoot.global_position
	proj.rotation = shoot.global_rotation
	world.register_projectile(proj)

func _use(_source:Entity):
	if cooldown_timer.is_stopped():
		if ammo > 0:
			ammo -= 1
			fire()
			cooldown_timer.start()
		else:
			var inv:Inventory = GameMngr.get_player_inv()
			if inv:
				if inv.take_magazine():
					ammo = mag_size
