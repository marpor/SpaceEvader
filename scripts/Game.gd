# Main game logic
extends Node2D

var mainMenu = null

enum { MENU, OPTIONS, PLAYING, FROZEN, GAME_OVER}

var state = -1

onready var CreditLink = find_node("CreditLink")

func _ready():
	randomize()

	load_config()

func _exit_tree():
	save_config()

func _physics_process(_delta):
	if Engine.get_physics_frames() % 30 == 0:
		# Every 30th frame ~ 2 times per second
		onResize()
		updateScore()

	if Global.use_multiplier:
		if Global.multiplier_timeout > 0.0:
			Global.multiplier_timeout -= _delta * Global.speedOverride * Global.speedScale()
		else:
			Global.score_multiplier = 1.0
			Global.score_extra_multiplier = 1.0

	if Engine.get_physics_frames() % 6 == 0:
		if state in [PLAYING, FROZEN]:
			if Global.speedOverride <= 0.0:
				set_state(FROZEN)
			else:
				set_state(PLAYING)

#	if Engine.get_physics_frames() % 120 == 0:
#		print("Orphans:")
#		print_stray_nodes()

func onResize():
	var w = get_viewport_rect().size.x
	var h = get_viewport_rect().size.y
	if w == Global.W and h == Global.H:
		return # no change

	Global.W = w
	Global.H = h
	Global.RADIUS = Vector2(Global.W, Global.H).length()/2
	Global.CENTER = Vector2(Global.W, Global.H)/2

	if Maps.currentMap:
		Maps.currentMap._on_resize(get_viewport_rect())

func set_state(state):
	if self.state == state:
		return # no change

	$UI/HUD.visible = state in [PLAYING, FROZEN]
	$UI/Options.visible = state in [OPTIONS]
	$UI/GameOver.visible = state in [GAME_OVER]

	if mainMenu:
		mainMenu.StartMenu.visible = state in [MENU]
		if state == MENU:
			mainMenu.menu()
	else:
		if state == MENU:
			# When debugging a single scene (with F6)
			get_tree().quit()

	Global.ship.visible = state in [PLAYING, FROZEN, GAME_OVER]

	if state == OPTIONS:
		# Don't show Continue & Retry button if we enter from the menu
		$UI/Options/ContinueButton.visible = self.state != MENU
		$UI/Options/RetryButton.visible = self.state != MENU

		$UI/Options/SensitivitySlider.value = Global.move_sensitivity
		$UI/Options/FullscreenCheckBox.pressed = OS.window_fullscreen

	# Handle freeze menu
	if not state in [PLAYING, FROZEN]:
		$UI/FreezeMenu.visible = false
	if state == FROZEN:
		$UI/FreezeMenu/AnimationPlayer.play("Appear")
	if self.state == FROZEN and state == PLAYING:
		$UI/FreezeMenu/AnimationPlayer.play("Disappear")

	self.state = state

var FloatText = preload("res://misc/FloatText.tscn")

export var travel = Vector2(0, -80)
export var duration = 2
export var spread = PI/2

func float_text(position, value, crit=false):
	var fct = FloatText.instance()
	fct.rect_position = position
	add_child(fct)
	fct.show_value(str(value), travel, duration, spread, crit)

func updateScore():
	if Global.score_multiplier > 1.0:
		$UI/HUD/ScoreLabel.text = "%.2f X, Score: %d" % [Global.score_multiplier * Global.score_extra_multiplier, Global.score]
	else:
		$UI/HUD/ScoreLabel.text = "Score: %d" % Global.score

func start():
	set_state(PLAYING)

	Global.t = 0
	Global.score = 0
	Global.ship.health = 1
	Global.ship.health_changed(Global.ship.health)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func restart():
	Maps.mapNo = Maps.mapNo-1
	Game.nextMap()

	start()

func game_over():
	set_state(GAME_OVER)

	if Global.score > Global.HIGHSCORE:
		Global.HIGHSCORE = Global.score
		save_config()

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	$UI/GameOver/ScoreLabel.text = "Score: %d" % Global.score

func nextMap():
	changeMap(Maps.next_map())

func changeMap(scene):
	print("changeTo ", scene.filename)
	if Maps.currentMap:
		clear()
		if Maps.currentMap.get_node("AnimationPlayer"):
			Maps.currentMap.get_node("AnimationPlayer").play("leave")
		else:
			Maps.currentMap.queue_free()

		Maps.currentMap._on_resize(get_viewport_rect())
	Global.ship.reset_position()

	Maps.currentMap = scene
	$Map.add_child(scene)

	Maps.currentMap.z_index = Maps.mapZ
	Maps.mapZ -= 1

func clear():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		e.free()

	var mets = get_tree().get_nodes_in_group("meteors")
	for e in mets:
		e.free()

	var shots = get_tree().get_nodes_in_group("shots")
	for e in shots:
		e.free()


func _unhandled_input(event):
	# Capture/un-capture mouse
	if event.is_action_pressed("ui_cancel"):
		if state == MENU:
			get_tree().quit()
		elif state == FROZEN and $UI/FreezeMenu/Hints:
			$UI/FreezeMenu/Hints.queue_free()
		elif state in [FROZEN, PLAYING]:
			set_state(OPTIONS)
		elif state == OPTIONS:
			set_state(FROZEN)
		else:
			set_state(MENU)

	if event.is_action_released("toggle_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen

func save_config():
	var config = ConfigFile.new()

	config.set_value("normal", "highscore", Global.HIGHSCORE)
	config.set_value("options", "move_sensitivity", Global.move_sensitivity)

	config.save("user://SpaceEvader.cfg")

func load_config():
	var config = ConfigFile.new()
	var err = config.load("user://SpaceEvader.cfg")
	if err != OK:
		return

	Global.HIGHSCORE = config.get_value("normal", "highscore") as int
	Global.move_sensitivity = config.get_value("options", "move_sensitivity", 1.0) as float

func _on_RetryButton_pressed():
	restart()

func _on_BackButton_pressed():
	set_state(MENU)

func _on_PauseButton_pressed():
	set_state(OPTIONS)

func _on_ContinueButton_pressed():
	set_state(PLAYING)

func _on_CloseHints_pressed():
	$UI/FreezeMenu/Hints.queue_free()

func _on_FullscreenCheckBox_toggled(button_pressed):
	OS.window_fullscreen = button_pressed

func _on_SensitivitySlider_value_changed(value):
	Global.move_sensitivity = value

func _on_CreditLink_pressed():
	OS.shell_open(Maps.currentMap.BackgroundURL)
