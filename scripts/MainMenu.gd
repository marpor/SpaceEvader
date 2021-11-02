extends Node2D

var menuMap = preload("res://maps/MenuMap.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Game.mainMenu = self
	menu()

func menu():
	$UI/StartMenu.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	Game.changeMap(menuMap.instance())
	Game.hideHUD()
	Global.ship.visible = false

	updateHighScore()

func died():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	updateHighScore()

func start():
	$UI/StartMenu.hide()
	Game.start()

func updateHighScore():
	$UI/StartMenu/CenterContainer2/HighScoreLabel.text = "HighScore: %d" % Global.HIGHSCORE

func _unhandled_input(event):
	if event.is_action_released("toggle_fullscreen"):
		_on_FullscreenButton_pressed()

#	elif event.is_action_released("quit"):
#		get_tree().quit()

func _on_FullscreenButton_pressed():
	OS.window_fullscreen = !OS.window_fullscreen

func _on_CreditLink_pressed():
	OS.shell_open("https://esahubble.org/images/heic2007a/")
