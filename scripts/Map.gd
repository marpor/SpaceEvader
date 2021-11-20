extends Node2D

var mapT = 0.0

var map = self
onready var background = $Map
var moving = true
var u = 0.0

export(int) var MAP_TIME = 30 # 0 for infinite map

export(float, 0.01, 10.0) var METEOR_DELAY = 0.300
var meteor_timeout = METEOR_DELAY

var ENEMY_DELAY = 1.000
var enemy_timeout = ENEMY_DELAY

export(int) var MeteorCount = 90

export(PackedScene) var Enemy1 = null
export(int) var Enemy1Count = 30
export(PackedScene) var Enemy2 = null
export(int) var Enemy2Count = 5
export(PackedScene) var Enemy3 = null
export(int) var Enemy3Count = 1

export(Color, RGB) var EnemyColor = Color.white

var ROTATION_SPEED = -3

export(String) var Location = ""
export(String) var BackgroundName = ""
export(String) var BackgroundCredit = ""
export(String) var BackgroundURL = ""

var enemies = []
func _ready():
	var enemy_count = 0
	if Enemy1:
		enemies.append([Enemy1Count, Enemy1])
		enemy_count += Enemy1Count
	if Enemy2:
		enemies.append([Enemy2Count, Enemy2])
		enemy_count += Enemy2Count
	if Enemy3:
		enemies.append([Enemy3Count, Enemy3])
		enemy_count += Enemy3Count
	if enemy_count > 0:
		ENEMY_DELAY = float(MAP_TIME) / enemy_count
	else:
		ENEMY_DELAY = 0

	if MeteorCount > 0:
		METEOR_DELAY = float(MAP_TIME) / MeteorCount
	else:
		METEOR_DELAY = 0

	Game.CreditLink.text = "Background credit: " + BackgroundCredit

func _enter_tree():
	Maps.currentMap = map
	Global.ship.visible = true

func _exit_tree():
	queue_free()

func _on_resize(rect):
	pass

func _process(delta):
	if not Global.is_alive():
		return

	delta *= Global.speedOverride

	Global.t += delta

	if MAP_TIME == 0:
		# Infinite map
		background.rotation_degrees += ROTATION_SPEED * delta
		Global.DIR = Vector2.RIGHT
	else:
		# Map with goal
		mapT += delta * Global.speedScale()

		# Move PathFollow in map
		var path = map.get_node("Path2D/PathFollow2D")
		var dt = delta * 1.0/MAP_TIME
		if Global.is_alive() and path.unit_offset >= 1.0 - dt*2:
			moving = false
		else:
			path.unit_offset = smoothstep(0, MAP_TIME, mapT)

		# Move background along path
		background.position = -path.global_position + Global.CENTER

		# Rotate DIR along path tangent
		Global.DIR = Vector2.RIGHT.rotated(path.global_rotation)

func _physics_process(delta):
	if not Global.is_alive():
		return

	delta *= Global.speedOverride * Global.speedScale()

	u += delta / MAP_TIME

	if not moving:
		# Stop spawning enemies when we've reached the end of the map
		return

	if METEOR_DELAY > 0:
		meteor_timeout -= delta
		if meteor_timeout <= 0.0:
			self.call_deferred("spawn_meteor")
			meteor_timeout = METEOR_DELAY

	if ENEMY_DELAY > 0:
		enemy_timeout -= delta
		if enemy_timeout <= 0.0:
			self.call_deferred("spawn_enemy")
			enemy_timeout = ENEMY_DELAY * rand_range(0.7, 1.3)

func spawn_meteor():
	var met = Meteors.makeInstance()
	Maps.currentMap.get_node("Map").add_child(met)

	met.scale *= .5
	met.global_position = Global.randStartPos()

func spawn_enemy():
	var e = Helpers.pickWeighted(enemies).instance()

	# Override color with Map's EnemyColor (from property)
	# If we don't set this, Enemy gets a random color from the palette
	if EnemyColor != Color.white:
		e.COLOR = EnemyColor

	# Maps added to root means they will move slower towards the player than to the sides.
	# While this is a bit wierd, it plays pretty well as it makes kiting enemies more effective.
	Maps.currentMap.add_child(e)

	# Alternatively, adding enemies to "Map" means they will move *with* the map, and at the same
	# speed in all directions. While more correct, it plays more monotone.
#	Maps.currentMap.get_node("Map").add_child(e)

	e.global_position = Global.randStartPos(35)
	e.speed *= rand_range(0.7, 1.3)
