extends Node2D

var enemies = [
	[ 50, preload("res://enemies/Enemy1.tscn")],
	[ 25, preload("res://enemies/Enemy2.tscn")],
	[ 15, preload("res://enemies/Enemy3.tscn")],
	[  2, preload("res://enemies/Boss1.tscn")],
	[  5, preload("res://enemies/Boss2.tscn")],
	[  2, preload("res://enemies/Boss3.tscn")],
	[  2, preload("res://enemies/Boss4.tscn")],
	[  2, preload("res://enemies/Boss5.tscn")],
	[  6, preload("res://enemies/Boss6.tscn")],
]

var meteors = [
	[ 30, preload("res://enemies/Meteor1.tscn")],
	[ 30, preload("res://enemies/Meteor2.tscn")],
	[ 20, preload("res://enemies/Meteor3.tscn")],
	[ 20, preload("res://enemies/Meteor4.tscn")],
	[ 10, preload("res://enemies/Meteor5.tscn")],
]

# Helper function that picks from an array of [weight, item] distributed
# according to weight.
func pickWeighted(arr):
	var total_weights = 0
	for v in arr:
		total_weights += v[0]

	var wTarget = randi() % total_weights
	var wAccumulated = 0
	for v in arr:
		wAccumulated += v[0]
		if wAccumulated > wTarget:
			return v[1]
	assert(false) # shouldn't get here!

func inc_clamp(var val, var increment, var maxVal):
	val += increment
	if val >= maxVal:
		return maxVal
	return val

func dec_clamp(var val, var increment, var minVal):
	val -= increment
	if val <= minVal:
		return minVal
	return val

var shot = preload("res://weapons/Shot.tscn")

var streak = preload("res://misc/Streak.tscn")
var streaks = []

var life = preload("res://misc/Life.tscn")

var menuMap = preload("res://maps/MenuMap.tscn")
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

var mapNo = -1 # -1 ensures nextMap() loads map 0
var map
var MAP_TIME = 30
var mapT = 0.0

var health = 1
var MAX_HEALTH = 3

var SPEED_MIN = 0.00
var SPEED_MAX = 1.00

onready var ship = $Ship

# Called when the node enters the scene tree for the first time.
func _ready():
	onResize()

	for n in 32:
		var s = streak.instance()
		s.show()
		streaks.append(s)
		self.add_child(s)

	menu()

func onResize():
	Global.W = get_viewport_rect().size.x
	Global.H = get_viewport_rect().size.y
	Global.RADIUS = Vector2(Global.W, Global.H).length()/2
	Global.CENTER = Vector2(Global.W, Global.H)/2

var mapZ = -1
func nextMap():
	if map:
		if map.get_node("AnimationPlayer"):
			map.get_node("AnimationPlayer").play("leave")

	mapNo += 1
	if mapNo >= maps.size():
		mapNo = 0

	map = maps[mapNo].instance()
	self.add_child(map)
	map.z_index = mapZ
	mapZ -= 1

	mapT = 0.0
	Global.moving = true
	Global.player_pos = Global.CENTER
	clear()

func menu():
	ship.hide()

	$UI/HUD.hide()
	$UI/StartMenu.show()
	$UI/GameOver.hide()

	$EnemyTimer.stop()
	$MeteorTimer.start()
	$LifeTimer.stop()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	Global.alive = true
	Global.moving = true
	clear()

	if map:
		if map.get_node("AnimationPlayer"):
			map.get_node("AnimationPlayer").play("leave")

	map = menuMap.instance()
	self.add_child(map)
	map.z_index = -1

	updateHighScore()

func health_changed(health):
	var shields = health-1
	for shield in ship.get_node("Shields").get_children():
		shield.visible = shields > 0
		shields -= 1

func die():
	if not Global.alive:
		return true

	health -= 1
	health_changed(health)

	if health > 0:
		return false # not dead yet!

	$UI/HUD.hide()
	$UI/StartMenu.hide()
	$UI/GameOver.show()

	$EnemyTimer.stop()
	$MeteorTimer.stop()
	$LifeTimer.stop()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	Global.alive = false
	Global.moving = false

	if Global.score > Global.HIGHSCORE:
		Global.HIGHSCORE = Global.score
		updateHighScore()

	return true

func start():
	ship.show()

	$UI/HUD.show()
	$UI/StartMenu.hide()
	$UI/GameOver.hide()

	$EnemyTimer.start()
	$MeteorTimer.start()
	$LifeTimer.start()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	Global.alive = true
	Global.moving = true

	seed(12345)
	mapT = 0.0
	Global.t = 0
	Global.score = 0
	health = 1
	health_changed(health)

	mapNo = -1
	nextMap()

func clear():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		e.queue_free()

	var mets = get_tree().get_nodes_in_group("meteors")
	for e in mets:
		e.queue_free()

func updateScore():
	$UI/HUD/ScoreLabel.text = "Score: %d" % Global.score
	$UI/GameOver/ScoreLabel.text = "Score: %d" % Global.score

func updateHighScore():
	$UI/StartMenu/CenterContainer2/HighScoreLabel.text = "HighScore: %d" % Global.HIGHSCORE

var joyOutput = Vector2()

func _on_touch_event(event, state):
	if event.position.x < Global.CENTER.x:
		if state:
			# left side of the screen -> joystick
			joyOutput = state.get_relative(128)/128 * 2
		else:
			joyOutput = Vector2()
	else:
		# right side of the screen -> buttons
		if event is InputEventScreenTouch:
			if event.pressed:
				shoot()

var touchingIndex = 0 # Index of first finger touching screen
func _input(event):
	if event is InputEventScreenTouch:
		# At least one finger is already touching the screen
		if touchingIndex > 0:
			if not event.pressed:
				# Initial finger released again -> block initial shoot
				if touchingIndex == event.index:
					# slight delay here to avoid having the emulated mouse click fire
#					yield(get_tree().create_timer(0.1), "timeout")
					touchingIndex = 0
#		else:
#			touchingIndex = event.index
#			get_tree().set_input_as_handled()

func _unhandled_input(event):
	if event.is_action_released("toggle_fullscreen"):
		_on_FullscreenButton_pressed()

	elif event.is_action_released("quit"):
		get_tree().quit()

	elif event is InputEventMouseMotion:
		var rel = event.relative * 1.5
		Global.player_pos += rel
		Global.speedOverride = inc_clamp(Global.speedOverride, .1, SPEED_MAX)

	elif event is InputEventMouseButton:
		if touchingIndex > 0:
			return # skip when touching
		if not event.pressed:
			shoot()

	elif event.is_action_pressed("shoot"):
		shoot()

	elif event is InputEventScreenDrag:
		# touch movement
		var rel = event.relative * 1.5
		Global.player_pos += rel
		Global.speedOverride = inc_clamp(Global.speedOverride, .1, SPEED_MAX)

	elif event is InputEventScreenTouch:
		# At least one finger is already touching the screen
		if touchingIndex > 0:
			if event.pressed:
				shoot()

func shoot():
	if not Global.alive:
		return

	Global.score -= 10

	var s = shot.instance()
	self.add_child(s)

func _on_MeteorTimer_timeout():
	if not Global.moving:
		return
	if Global.speedOverride <= 0.0:
		return

	var met = pickWeighted(meteors).instance()
	self.add_child(met)

func _on_EnemyTimer_timeout():
	if not Global.moving:
		return
	if Global.speedOverride <= 0.0:
		return

	var e = pickWeighted(enemies).instance()
	self.add_child(e)

func _on_LifeTimer_timeout():
	return # not used - fixed in maps instead
	if not Global.moving:
		return
	if Global.speedOverride <= 0.0:
		return

	var background = map.get_node("Map")
	var l = life.instance()
	l.position = -background.position + Global.CENTER + Global.randStartPos()
	background.add_child(l)

func _process(delta):
	if joyOutput.length() > 0.0:
		Global.player_pos += joyOutput * 1500 * delta

	Global.player_pos.x = clamp(Global.player_pos.x, 0, Global.W)
	Global.player_pos.y = clamp(Global.player_pos.y, 0, Global.H)

	ship.position = Global.player_pos
#	ship.rotation = Global.DIR.angle() - Vector2.UP.angle()

	Global.speedOverride = dec_clamp(Global.speedOverride, delta*3, SPEED_MIN)

	if not Global.moving:
		return

	delta *= Global.speedOverride

	if protectedTime > 0.0:
		protectedTime -= delta
		# blink ship
		ship.visible = fmod(protectedTime, .2*protectedTime) > .1*protectedTime
	else:
		ship.visible = true

	Global.t += delta
	mapT += delta

	# Move PathFollow in map
	var path = map.get_node("Path2D/PathFollow2D")
	var dt = delta * 1.0/MAP_TIME
	if Global.alive and path.unit_offset >= 1.0 - dt*2:
		Global.moving = false
	else:
		path.unit_offset = smoothstep(0, MAP_TIME, mapT)

	# Move background along path
	var background = map.get_node("Map")
	background.position = -path.global_position + Global.CENTER

	# Rotate DIR along path tangent
	Global.DIR = Vector2.RIGHT.rotated(path.global_rotation)

var frame = 0
var title = "Space Evader"

func _physics_process(_delta):
	frame += 1
	if frame % 10:
		# Approx 6 times per second
		onResize()
		updateScore()
		OS.set_window_title(title + " | fps: " + str(Engine.get_frames_per_second()))

func _on_Ship_body_entered(_body):
	# Meteors use bodies
	die()

var protectedTime = 0.0
func _on_Ship_area_entered(area):
	area.get_node("CollisionPolygon2D").set_deferred("disabled", true)
	if area.get_collision_layer_bit(8):
		# Layer: Goal
		call_deferred("nextMap")
	elif area.get_collision_layer_bit(7):
		# Layer: Life
		if health < MAX_HEALTH:
			health += 1
		health_changed(health)
		area.queue_free()
	else:
		# We hit something else - an enemy or meteor
		# See if it kills us, or if we have a shield?
		if protectedTime > 0.0 or not die():
			# Protect against further damage for a short time
			# (and effectively use the shield as a weapon)
			protectedTime = .5

			# Kill stuff!
			if area.has_method("shot"):
				while area.life > 0:
					area.shot(area)

func _on_FullscreenButton_pressed():
	OS.window_fullscreen = !OS.window_fullscreen

func _on_CreditLink_pressed():
	OS.shell_open("https://esahubble.org/images/heic2007a/")
