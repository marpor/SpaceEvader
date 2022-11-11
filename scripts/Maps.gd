# Maps.gd - Preloads all maps, and give us access to them in the desired order
extends Node

var maps = [
	preload("res://maps/IntroMap.tscn"),
	preload("res://maps/IntroMap2.tscn"),

	preload("res://maps/Mission1a.tscn"),
	preload("res://maps/Mission1b.tscn"),
	preload("res://maps/Mission1c.tscn"),

	preload("res://maps/Mission2a.tscn"),
	preload("res://maps/Mission2b.tscn"),
	preload("res://maps/Mission2c.tscn"),

	preload("res://maps/Mission3a.tscn"),
	preload("res://maps/Mission3b.tscn"),
	preload("res://maps/Mission3c.tscn"),

	preload("res://maps/Mission4a.tscn"),
	preload("res://maps/Mission4b.tscn"),
	preload("res://maps/Mission4c.tscn"),
	preload("res://maps/Mission4d.tscn"),
]

var mapNo = -1 # -1 ensures next_map() loads map 0
var currentMap = null

var mapZ = -1

func next_map():
	mapNo += 1

	# Reset score when going from tutorial to main maps
	if Maps.mapNo == 2:
		Global.score = 0

	if mapNo >= maps.size():
		mapNo = 2 # after tutorial

	return maps[mapNo].instance()
