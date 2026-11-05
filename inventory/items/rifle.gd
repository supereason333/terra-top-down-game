extends Item2D

@export var audio:AudioStream
@export var energy_use := 5.0

@onready var cooldown_timer:Timer = $CooldownTimer
@onready var shoot:Marker2D = $Shoot
var projectiles:ProjectileMngr

var firing := false

func _ready() -> void:
	var world := GameMngr.get_world()
	if !world: return
	projectiles = world.get_projectiles()

func fire(source:Entity):
	if !projectiles: return

	if source is Player:
		if !source.get_power().get_energy(energy_use):
			return

	projectiles.register_projectile(&"bounce_laser", global_transform)
#
# 	var player := AudioStreamPlayer.new()
# 	player.stream = audio
# 	player.autoplay = true
# 	player.finished.connect(player.queue_free)
# 	player.volume_db = -10
# 	add_child(player)

func _use(_source:Entity):
	if cooldown_timer.is_stopped():
		fire(_source)
		cooldown_timer.start()
