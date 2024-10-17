# MainMenu.gd - Logic for the Main Menu
# Only used by MainMenu.tscn
extends Node2D

var menuMap = "res://maps/MenuMap.tscn"

onready var FullscreenButton = find_node("FullscreenButton")
onready var QuitButton = find_node("QuitButton")
onready var OptionsButton = find_node("OptionsButton")
onready var HighScoreLabel = find_node("HighScoreLabel")
onready var VersionLink = find_node("VersionLink")

onready var UI = find_node("UI")
onready var StartMenu = find_node("StartMenu")

func _ready():
	var window_to_root = Transform2D.IDENTITY.scaled(get_tree().root.size / OS.window_size)
	var saferect = window_to_root.xform(OS.get_window_safe_area())
	var parent_to_root = StartMenu.get_viewport_transform() * StartMenu.get_global_transform() * StartMenu.get_transform().affine_inverse()
	var root_to_parent = parent_to_root.affine_inverse()
	saferect = root_to_parent.xform(saferect)
	StartMenu.set_position(saferect.position, false)
	StartMenu.set_size(saferect.size, false)

	Game.mainMenu = self

	if OS.has_feature("mobile"):
		QuitButton.hide()
		FullscreenButton.hide()

	if OS.has_feature("web"):
		QuitButton.hide()

	Game.set_state(Game.MENU)

	VersionLink.text = \
		"Version %d.%d - Copyright 2021 marpor" \
		% [Version.major, Version.minor]

func menu():
	Game.changeMap(load(menuMap).instance())

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
