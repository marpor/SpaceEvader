extends Node2D

var menuMap = preload("res://maps/MenuMap.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Game.mainMenu = self
	if OS.window_fullscreen:
		# If fullscreen at start it means we're on a device that only does fullscreen
		$UI/StartMenu/CenterContainer/HBoxContainer/FullscreenButton.hide()

	Game.load_highscore()
	menu()

func menu():
	$UI/StartMenu.show()

	Game.changeMap(menuMap.instance())
	Game.hideHUD()
	Global.ship.visible = false

	updateHighScore()

func start():
	$UI/StartMenu.hide()
	Game.start()

func updateHighScore():
	$UI/StartMenu/CenterContainer2/HighScoreLabel.text = "HighScore: %d" % Global.HIGHSCORE

func _on_FullscreenButton_pressed():
	OS.window_fullscreen = !OS.window_fullscreen

func _on_CreditLink_pressed():
	OS.shell_open("https://esahubble.org/images/heic2007a/")
