extends Node2D

var menuMap = preload("res://maps/MenuMap.tscn")

onready var FullscreenButton = find_node("FullscreenButton")
onready var QuitButton = find_node("QuitButton")
onready var OptionsButton = find_node("OptionsButton")
onready var HighScoreLabel = find_node("HighScoreLabel")

onready var UI = find_node("UI")
onready var StartMenu = find_node("StartMenu")
#onready var StartMenu = find_node("StartMenu")
#onready var StartMenu = find_node("StartMenu")

# Called when the node enters the scene tree for the first time.
func _ready():
	Game.mainMenu = self

	if 0 or OS.has_feature("mobile"):
		QuitButton.hide()
		FullscreenButton.hide()

	if 0 or OS.has_feature("web"):
		QuitButton.hide()

	Game.load_highscore()
	menu()

func menu():
	StartMenu.show()

	Game.changeMap(menuMap.instance())
	Game.hideHUD()
	Global.ship.visible = false

	updateHighScore()

func hide():
	StartMenu.hide()
	FullscreenButton.hide()

func updateHighScore():
	HighScoreLabel.text = "HighScore: %d" % Global.HIGHSCORE

func _on_FullscreenButton_pressed():
	OS.window_fullscreen = !OS.window_fullscreen

func _on_CreditLink_pressed():
	OS.shell_open("https://esahubble.org/images/heic2007a/")

func _on_TutorialButton_pressed():
	hide()
	Game.start(0) # Map 0 is the tutorial

func _on_MissionsButton_pressed():
	hide()
	Game.start(1) # Map 1 is the first mission

func _on_ChallengesButton_pressed():
	pass # Replace with function body.

func _on_QuitButton_pressed():
	get_tree().quit()
