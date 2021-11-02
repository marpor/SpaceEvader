extends Node2D

var MAP_TIME = 30
var mapT = 0.0

var map = self
onready var background = $Map
var moving = true

func _enter_tree():
	Maps.currentMap = map

func _exit_tree():
	queue_free()

func _process(delta):
	if not Global.is_alive():
		return

	delta *= Global.speedOverride

	Global.t += delta
	mapT += delta

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
