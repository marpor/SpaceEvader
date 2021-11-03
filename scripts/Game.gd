# Main game logic
extends Node2D

var mainMenu = null

func _ready():
	randomize()

func _physics_process(_delta):
	if Engine.get_physics_frames() % 30 == 0:
		# Every 30th frame ~ 2 times per second
		onResize()
		updateScore()

func onResize():
	Global.W = get_viewport_rect().size.x
	Global.H = get_viewport_rect().size.y
	Global.RADIUS = Vector2(Global.W, Global.H).length()/2
	Global.CENTER = Vector2(Global.W, Global.H)/2

func updateScore():
	$UI/HUD/ScoreLabel.text = "Score: %d" % Global.score

func hideHUD():
	$UI/HUD.hide()

func start():
	clear()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$UI/HUD.show()
	$UI/GameOver.hide()

	Global.t = 0
	Global.score = 0
	Global.ship.health = 1
	Global.ship.health_changed(Global.ship.health)
	Global.ship.visible = true

	Maps.mapNo = -1
	Game.nextMap()

func game_over():
	if Global.score > Global.HIGHSCORE:
		Global.HIGHSCORE = Global.score

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	hideHUD()
	$UI/GameOver/ScoreLabel.text = "Score: %d" % Global.score
	$UI/GameOver.show()

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
	start()

func _on_BackButton_pressed():
	$UI/GameOver.hide()
	mainMenu.menu()

func _on_PauseButton_pressed():
	$UI/FreezeMenu.hide()
	$UI/Options.show()

func _on_CloseHints_pressed():
	$UI/FreezeMenu/Hints.queue_free()
