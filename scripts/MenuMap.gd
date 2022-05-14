# MenuMap.gd - Special logic for MenuMap.tscn. Specifically we're
extends Node2D

var MAP_TIME = 240
onready var mapT = rand_range(0, MAP_TIME)

var map = self
onready var background = $Map

var moving = true

export(String) var BackgroundName = ""
export(String) var BackgroundCredit = ""
export(String) var BackgroundURL = ""

func _enter_tree():
	Maps.currentMap = map

func _exit_tree():
	queue_free()

func _on_resize(rect):
	pass

func _process(delta):
	mapT += delta

	# Move PathFollow in map
	var path = map.get_node("Path2D/PathFollow2D")
	path.unit_offset = mapT * 1.0/MAP_TIME

	# Move background along path
	background.position = -path.global_position + Global.CENTER

	# Rotate DIR along path tangent
	Global.DIR = Vector2.RIGHT.rotated(path.global_rotation)
