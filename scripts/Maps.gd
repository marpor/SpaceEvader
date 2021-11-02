extends Node

var maps = [
	preload("res://maps/Map1.tscn"),
	preload("res://maps/Map2.tscn"),
	preload("res://maps/Map3.tscn"),
	preload("res://maps/Map4.tscn"),
	preload("res://maps/Map5.tscn"),
	preload("res://maps/Map6.tscn"),
#	preload("res://maps/heic1917a.tscn"),
#	preload("res://maps/heic2007a.tscn"),
#	preload("res://maps/opo0328a.tscn"),
]

var mapNo = -1 # -1 ensures next_map() loads map 0
var currentMap = null

var mapZ = -1

func next_map():
	mapNo += 1
	if mapNo >= maps.size():
		mapNo = 0

	return maps[mapNo].instance()

