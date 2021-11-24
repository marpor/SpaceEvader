extends Node2D

var menuMap = preload("res://maps/MenuMap.tscn")

onready var FullscreenButton = find_node("FullscreenButton")
onready var QuitButton = find_node("QuitButton")
onready var OptionsButton = find_node("OptionsButton")
onready var HighScoreLabel = find_node("HighScoreLabel")
onready var VersionLink = find_node("VersionLink")

onready var UI = find_node("UI")
onready var StartMenu = find_node("StartMenu")

func _ready():
	Game.mainMenu = self

	if 0 or OS.has_feature("mobile"):
		QuitButton.hide()
		FullscreenButton.hide()

	if 0 or OS.has_feature("web"):
		QuitButton.hide()

	Game.set_state(Game.MENU)
	
	VersionLink.text = \
		"Version %d.%d - Copyright 2021 marpor" \
		% [Version.minor, Version.major]

func menu():
	Game.changeMap(menuMap.instance())

	updateHighScore()

func updateHighScore():
	HighScoreLabel.text = "HighScore: %d" % Global.HIGHSCORE

func _on_OptionsButton_pressed():
	Game.set_state(Game.OPTIONS)

func _on_FullscreenButton_pressed():
	OS.window_fullscreen = !OS.window_fullscreen

func _on_CreditLink_pressed():
	OS.shell_open("https://esahubble.org/images/heic2007a/")

func _on_VersionLink_pressed():
	OS.shell_open("https://se.m8y.net/")

func _on_TutorialButton_pressed():
	Maps.mapNo = -1 # nextMap loads first map
	Game.nextMap()
	Game.start()

func _on_MissionsButton_pressed():
	Maps.mapNo = 1 # nextMap loads first non-tutorial map
	Game.nextMap()
	Game.start()

func _on_ChallengesButton_pressed():
	pass # Replace with function body.

func _on_QuitButton_pressed():
	get_tree().quit()
