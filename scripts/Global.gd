# Global.gd - Various game state shared between other scripts.
extends Node

# Persisted options
var move_sensitivity = 1.0
var music_volume = -10
var sound_volume = 0
var STARTING_SPEED = 0.25 # Start speed factor (user defineable)
var HIGHSCORE = 0
var AUTO_PAUSE = false

# Constants
const title = "Space Evader"
const SPEEDUP_MINUTES = 5.0  # Increase speed factor (by 1) every N minutes (affects difficulty)

# Screen vars
var W = 1024
var H = 576
var CENTER = Vector2(W/2, H/2)
var RADIUS = CENTER.length()

# Game vars
var t = 0 # Time from game start. Increased by
var score = 0
var moving = true
var DIR = Vector2.RIGHT
var ship = null

var speedOverride = 0.0

# Score multiplier
var use_multiplier = true
var score_multiplier = 1.0
var score_extra_multiplier = 1.0
var multiplier_timeout = 0.0

# Metrics
var instanceCount = 0

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
	return Global.STARTING_SPEED + Global.t/(Global.SPEEDUP_MINUTES*60)

func _physics_process(_delta):
	if Engine.get_physics_frames() % 60 == 0:
		# Every 60th frame ~ 1 time per second (get_frames_per_second doesn't update more often anyway)
		OS.set_window_title(title + " - " + str(Engine.get_frames_per_second()) + " FPS")
