extends Node2D

var MAP_TIME = 30
var mapT = 0.0

var map = self
onready var background = $Map
var moving = true

export var ENEMY_DELAY = 1.000
var enemy_timeout = ENEMY_DELAY

export var METEOR_DELAY = 0.300
var meteor_timeout = METEOR_DELAY

func _enter_tree():
	Maps.currentMap = map

func _exit_tree():
	queue_free()

func _process(delta):
	if not Global.is_alive():
		return

	delta *= Global.speedOverride

	Global.t += delta
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

	meteor_timeout -= delta
	if meteor_timeout <= 0.0:
		self.call_deferred("spawn_meteor")
		meteor_timeout = METEOR_DELAY

	if not moving:
		# Stop spawning enemies when we've reached the end of the map
		return

	enemy_timeout -= delta
	if enemy_timeout <= 0.0:
		self.call_deferred("spawn_enemy")
		enemy_timeout = ENEMY_DELAY

func spawn_meteor():
	var met = Meteors.makeInstance()
	Maps.currentMap.add_child(met)

func spawn_enemy():
	var e = Enemies.makeInstance()
	e.position = Global.randStartPos(35)

	Maps.currentMap.add_child(e)
