extends Node

var t = 0
var DIR = Vector2.RIGHT #.rotated(deg2rad(-30))
var score = 0
var alive = false
var moving = true
var W = 100
var H = 100
var CENTER = Vector2()
var RADIUS = 100.0
var HIGHSCORE = 0
var player_pos = Vector2()

var instanceCount = 0

func randStartPos(deg = 55):
	var dir = -Global.DIR
	dir = dir.rotated(rand_range(deg2rad(-deg), deg2rad(deg)))
	return CENTER + RADIUS * -dir

#func randStartPosTop():


func speedScale():
	# Add inital speed every 3 minutes
	return 1 + Global.t/(3*60)
	#return 1.0
	#return 1 + log(5+Global.t*10) - log(5)
