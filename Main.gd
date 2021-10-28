extends Node2D

var enemies = [
	[ 50, preload("res://enemies/Enemy1.tscn")],
	[ 25, preload("res://enemies/Enemy2.tscn")],
	[  5, preload("res://enemies/Enemy3.tscn")],
	[  2, preload("res://enemies/Boss1.tscn")],
	[  1, preload("res://enemies/Boss2.tscn")],
]

var meteors = [
	[ 30, preload("res://enemies/Meteor1.tscn")],
	[ 30, preload("res://enemies/Meteor2.tscn")],
	[ 20, preload("res://enemies/Meteor3.tscn")],
	[ 20, preload("res://enemies/Meteor4.tscn")],
	[ 10, preload("res://enemies/Meteor5.tscn")],
]

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
	assert(0) # shouldn't get here!

var enemyFragmentTextures = [
	preload("res://artwork/Enemy1A.png"),
	preload("res://artwork/Enemy1B.png"),
	preload("res://artwork/Enemy1C.png"),
	preload("res://artwork/Enemy1D.png"),
]
var shot = preload("res://weapons/Shot.tscn")

var streak = preload("res://misc/Streak.tscn")
var streaks = []

var fragment = preload("res://enemies/Fragment.tscn")

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
#var MAP_TIME = 1.5 * 60
var MAP_TIME = 30
var mapT = 0.0
var health = 1

onready var healthBar = $UI/HUD/HealthBar

# Called when the node enters the scene tree for the first time.
func _ready():
#	TouchHelper.connect("TouchStateEvent", self, "_on_touch_event")

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
	$Ship.hide()

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

func die():
	if not Global.alive:
		return true

	health -= 1
	healthBar.update_life(health)
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
	$Ship.show()

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
	healthBar.update_life(health)

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

func _unhandled_input(event):
	if event.is_action_released("toggle_fullscreen"):
		_on_FullscreenButton_pressed()

	elif event.is_action_released("quit"):
		get_tree().quit()

	elif event is InputEventMouseMotion:
		Global.player_pos += event.relative * 1.5

	elif event is InputEventMouseButton:
		if event.pressed:
			shoot()

	elif event.is_action_pressed("shoot"):
		shoot()

	elif event is InputEventScreenTouch:
		if event.pressed:
			shoot()

func addShot(source, target, ang = 0):
	if Global.instanceCount > 100:
		# Don't add more instances to avoid hitting exponential slowdown
		return

	if not target:
		return

	for tex in target.fragmentTextures:
		var spreadAngle = 35
		ang = rand_range(-spreadAngle, spreadAngle)

		var s = fragment.instance()
		s.get_node("Sprite").texture = tex
		self.add_child(s)

		s.speed *= rand_range(0.5, 0.9)
		s.dir = source.dir
		s.position = source.position
		s.rotate(deg2rad(ang))
		s.dir = s.dir.rotated(deg2rad(ang))
		s.angular_velocity = rand_range(-4, 4)
		s.modulate = target.modulate
#		s.scale = target.get_node("CollisionPolygon2D").scale
		s.scale = target.scale

		s.connect("shot", self, "_on_shot")

func _on_shot(source, target):
	addShot(source, target, 15)

func shoot():
	if not Global.alive:
		return

	Global.score -= 10

	var s = shot.instance()
	self.add_child(s)
	s.connect("shot", self, "_on_shot")

func _on_MeteorTimer_timeout():
	if not Global.moving:
		return

	var met = pickWeighted(meteors).instance()
	self.add_child(met)

func _on_EnemyTimer_timeout():
	if not Global.moving:
		return

	var e = pickWeighted(enemies).instance()
	self.add_child(e)

func _on_LifeTimer_timeout():
	return # not used - fixed in maps instead
	if not Global.moving:
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

	$Ship.position = Global.player_pos
#	$Ship.rotation = Global.DIR.angle() - Vector2.UP.angle()

	if not Global.moving:
		return

	Global.t += delta
	mapT += delta

	# Move PathFollow in map
	var path = map.get_node("Path2D/PathFollow2D")
	var dt = delta * 1.0/MAP_TIME
	if Global.alive and path.unit_offset >= 1.0 - dt*2:
#		path.unit_offset = 1.0
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

func _on_Ship_area_entered(area):
	area.get_node("CollisionPolygon2D").set_deferred("disabled", true)
	if area.get_collision_layer_bit(8): # Layer: Goal
#		area.queue_free()
		call_deferred("nextMap")
	elif area.get_collision_layer_bit(7): # Layer: Life
		if health < 3:
			health += 1
		healthBar.update_life(health)
		area.queue_free()
	else:
		# Enememy or meteor
		if not die():
			# What doesn't kill you -- disappears!?
			# If really dead, we want to keep enemy around so the player can see
			# what happened on the game over screen...
			area.queue_free()


func _on_FullscreenButton_pressed():
	OS.window_fullscreen = !OS.window_fullscreen

func _on_CreditLink_pressed():
	OS.shell_open("https://esahubble.org/images/heic2007a/")
