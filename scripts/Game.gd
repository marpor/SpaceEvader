# Main game logic
extends Node2D

var mainMenu = null
onready var monitor = $Monitor

enum { MENU, OPTIONS, PLAYING, FROZEN, GAME_OVER}

var state = MENU

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

#	if Engine.get_physics_frames() % 120 == 0:
#		print("Orphans:")
#		print_stray_nodes()

func onResize():
	Global.W = get_viewport_rect().size.x
	Global.H = get_viewport_rect().size.y
	Global.RADIUS = Vector2(Global.W, Global.H).length()/2
	Global.CENTER = Vector2(Global.W, Global.H)/2

func state_changed(state):
	$UI/HUD.visible = state in [PLAYING, FROZEN]
	$UI/Options.visible = state in [OPTIONS]
	$UI/GameOver.visible = state in [GAME_OVER]
	$UI/FreezeMenu.visible = state in [FROZEN]

	if mainMenu:
		mainMenu.StartMenu.visible = state in [MENU]

	Global.ship.visible = state in [PLAYING, FROZEN, GAME_OVER]

func set_state(state):
	self.state = state
	state_changed(state)

func updateScore():
	$UI/HUD/ScoreLabel.text = "Score: %d" % Global.score

func start():
	set_state(PLAYING)

	clear()

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
	state_changed(Game.state)
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

func _on_RetryButton_pressed():
	restart()

func _on_BackButton_pressed():
	set_state(MENU)
	mainMenu.menu()

func _on_PauseButton_pressed():
	set_state(OPTIONS)

func _on_CloseHints_pressed():
	$UI/FreezeMenu/Hints.queue_free()

func _unhandled_input(event):
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

	Global.HIGHSCORE = int(config.get_value("normal", "highscore"))
	Global.move_sensitivity = float(config.get_value("options", "move_sensitivity"))
