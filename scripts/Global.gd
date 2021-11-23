extends Node

var title = "Space Evader"

var t = 0

var score = 0
var moving = true
var HIGHSCORE = 0

var W = 1024
var H = 576
var CENTER = Vector2(W/2, H/2)
var RADIUS = CENTER.length()

var DIR = Vector2.RIGHT #.rotated(deg2rad(-30))

var ship = null

var instanceCount = 0

var speedOverride = 0.0

var move_sensitivity = 1.0

# Score multiplier
var use_multiplier = false
var score_multiplier = 1.0
var multiplier_timeout = 0.0

func get_player_position():
	if not ship:
		return CENTER
	return ship.position

func is_alive():
	if not ship:
		return false
	return ship.is_alive()

func randStartPos(deg = 55):
	deg /= 2
	var dir = -Global.DIR
	dir = dir.rotated(deg2rad(Helpers.randSpread(deg)))
	return CENTER + RADIUS * -dir

func speedScale():
	# Add inital speed every 5 minutes
	return 1 + Global.t/(5*60)
	#return 1.0
	#return 1 + log(5+Global.t*10) - log(5)

func _physics_process(_delta):
	if Engine.get_physics_frames() % 60 == 0:
		# Every 60th frame ~ 1 time per second (get_frames_per_second doesn't update more often anyway)
		OS.set_window_title(title + " - " + str(Engine.get_frames_per_second()) + " FPS")
