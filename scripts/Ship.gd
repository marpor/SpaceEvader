extends Area2D

var protectedTime = 0.0

#export var health = 1 setget health_changed
var health = 1
var MAX_HEALTH = 3

var can_move = true
var can_shoot = true

# Time of last move
var last_move_ticks = 0.0

var SENSITIVITY_TOUCH = 1.5
var SENSITIVITY_MOUSE = 1.0

var SPEED_MIN = 0.00
var SPEED_MAX = 1.00

func _ready():
	pass

func _enter_tree():
	Global.ship = self
	health_changed(health)

func _exit_tree():
	Global.ship = null

var touchingIndex = -1 # Index of first finger touching screen
var using_touch = false # Used ot skip mouse events when using touch
var distanceTouched = 0.0 # Used to check if initial touch was intended as a shot

func _input(event):
	if event is InputEventScreenTouch:
		# At least one finger is already touching the screen
		if touchingIndex >= 0:
			if not event.pressed:
				# Initial finger released again -> block initial shoot
				if touchingIndex == event.index:
					touchingIndex = -1

		# Starting new touch move
		else:
			if can_move:
				distanceTouched = 0.0
				touchingIndex = event.index
				get_tree().set_input_as_handled()


func _unhandled_input(event):
	# Capture/un-capture mouse
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#			get_tree().set_input_as_handled()
#			Game.set_state(Game.OPTIONS)

	elif event.is_action_pressed("click"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			using_touch = false # clear - in case user switched from touch to mouse
			get_tree().set_input_as_handled()

	if event.is_action_pressed("shoot"):
		shoot()

	# Only move player when mouse is captured and NOT using touch
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and !using_touch:
		if can_move and event is InputEventMouseMotion:
			var rel = event.relative * SENSITIVITY_MOUSE
			move(rel)

		elif event is InputEventMouseButton:
			if event.pressed:
				shoot()

		elif event.is_action_pressed("click"):
			shoot()

	if event is InputEventScreenDrag:
		# touch movement
		using_touch = true
		if can_move and touchingIndex == event.index:
			var rel = event.relative * SENSITIVITY_TOUCH
			distanceTouched += rel.length()
			move(rel)
	elif event is InputEventPanGesture:
		pass

	elif event is InputEventScreenTouch:
		# At least one finger is already touching the screen
		if touchingIndex >= 0:
			if event.pressed:
				shoot()
		# ... or first finger not used to actually move
		elif distanceTouched < 10.0:
			shoot()

func _process(delta):
	if not is_alive():
		return

	position.x = clamp(position.x, 0, Global.W)
	position.y = clamp(position.y, 0, Global.H)

	position = position
#	rotation = Global.DIR.angle() - Vector2.UP.angle()

func _physics_process(delta):
	Global.speedOverride = Helpers.dec_clamp(Global.speedOverride, Global.speedScale()*delta*2, SPEED_MIN)

	if protectedTime > 0.0:
		protectedTime -= delta * Global.speedOverride
		# blink ship
		$Parts.visible = fmod(protectedTime, .2*protectedTime) > .1*protectedTime
	else:
		$Parts.visible = true

func _on_Ship_area_entered(area):
	area.get_node("CollisionPolygon2D").set_deferred("disabled", true)
	if area.get_collision_layer_bit(8):
		# Layer: Goal
		Game.call_deferred("nextMap")
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

			area.call_deferred("collided_with_ship", self)

func move(relative):
	last_move_ticks = OS.get_ticks_msec()
	if not is_alive():
		return

	# Increase speed
	var inc=.1*relative.length()
	Global.speedOverride = Helpers.inc_clamp(Global.speedOverride, inc, SPEED_MAX)

	# Move - respecting sensitivity set in Options
	relative *= Global.move_sensitivity
	position += relative

func is_alive():
	return health > 0

func die():
	if not is_alive():
		return true

	health -= 1
	health_changed(health)

	if health > 0:
		return false # not dead yet!

	Game.call_deferred("game_over")
	return true

func reset_position():
	position = Vector2(Global.W/3, Global.H/2)

var ShotScene = preload("res://misc/Shot.tscn")
func shoot():
	if not can_shoot:
		return
	if not is_alive():
		return
	if not Maps.currentMap:
		return

	Global.speedOverride = Helpers.inc_clamp(Global.speedOverride, 1/Global.speedScale(), SPEED_MAX)

	Global.score -= 10

	var s = ShotScene.instance()

	s.attached = false
	#s.dir = Global.DIR
	s.dir = Vector2.RIGHT
	s.rotate(s.dir.angle() - Vector2.UP.angle())
	var ship_tip = Global.get_player_position() + 30 * s.dir
	s.position = ship_tip
	s.speed *= Global.speedScale()

	Maps.currentMap.add_child(s)

func health_changed(health):
	var shields = health-1
	for shield in get_node("Shields").get_children():
		shield.visible = shields > 0
		shields -= 1
