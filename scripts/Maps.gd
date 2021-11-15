extends Node

var maps = [
	preload("res://maps/Mission1a.tscn"),
	preload("res://maps/Mission2a.tscn"),

	preload("res://maps/Mission3a.tscn"),
	preload("res://maps/Mission3b.tscn"),
	preload("res://maps/Mission3c.tscn"),

	preload("res://maps/Mission4a.tscn"),
	preload("res://maps/Mission4b.tscn"),
	preload("res://maps/Mission4c.tscn"),

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

