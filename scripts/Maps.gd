# Maps.gd - Preloads all maps, and give us access to them in the desired order
extends Node

var maps = [
	"res://maps/IntroMap.tscn",
	"res://maps/IntroMap2.tscn",

	"res://maps/Mission1a.tscn",
	"res://maps/Mission1b.tscn",
	"res://maps/Mission1c.tscn",

	"res://maps/Mission2a.tscn",
	"res://maps/Mission2b.tscn",
	"res://maps/Mission2c.tscn",

	"res://maps/Mission3a.tscn",
	"res://maps/Mission3b.tscn",
	"res://maps/Mission3c.tscn",

	"res://maps/Mission4a.tscn",
	"res://maps/Mission4b.tscn",
	"res://maps/Mission4c.tscn",
	"res://maps/Mission4d.tscn",
]

var missions = [
	["Training", [
		"res://maps/IntroMap.tscn",
		"res://maps/IntroMap2.tscn",
	]],
	["Earth", [
		"res://maps/Mission1a.tscn",
		"res://maps/Mission1b.tscn",
		"res://maps/Mission1c.tscn",
	]],
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

	return load(maps[mapNo]).instance()
