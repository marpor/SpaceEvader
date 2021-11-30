extends Node

var LoopingPlayer = preload("res://scripts/LoopingPlayer.gd")
var SoundPlayer = preload("res://scripts/SoundPlayer.gd")

var musicPlayer = null
var shieldPlayer = null
var enemyPlayer = null
var meteorPlayer = null

func _init():
	musicPlayer = LoopingPlayer.new()
	add_child(musicPlayer)

	shieldPlayer = SoundPlayer.new(2, "Master")
	add_child(shieldPlayer)

	meteorPlayer = SoundPlayer.new(5, "Meteor")
	add_child(meteorPlayer)

	enemyPlayer = SoundPlayer.new(5, "Environment")
	add_child(enemyPlayer)

	musicAuto()

func music(state):
	pass

func musicAuto():
	var menuMusic = preload("res://sounds/track1.wav")
	musicPlayer.play(menuMusic, -10)

func shot(pos):
	var soundShot = preload("res://sounds/shot2.wav")
	enemyPlayer.play(soundShot)

func move(pos, relative):
	var snd = preload("res://sounds/swoosh1.wav")
#	play(pos, snd, "Environment")

func meteorHit(pos, life):
	var rockhits = [
		preload("res://sounds/rock1.wav"),
		preload("res://sounds/rock2.wav"),
		preload("res://sounds/rock3.wav"),
		preload("res://sounds/rock4.wav"),
		preload("res://sounds/rock5.wav"),
	]
	meteorPlayer.play_distanced(pos, Helpers.pickRandom(rockhits))

#	if life > 0:
#		play(pos, Helpers.pickRandom(rockhits))
#	else:
#		play(pos, soundMeteorDied)

var soundEnemyHit = preload("res://sounds/metal1.wav")
var soundEnemyDied = preload("res://sounds/metal2.wav")

func enemyHit(pos, life):
	if life > 0:
		enemyPlayer.play_distanced(pos, soundEnemyHit)
	else:
		enemyPlayer.play_distanced(pos, soundEnemyDied)

func shield(pos):
	var soundShield = preload("res://sounds/shield3.wav")
	shieldPlayer.play(soundShield)

func playerHit(pos, health):
	var soundShieldLoss = preload("res://sounds/shieldloss2.wav")
	if health > 0:
		shieldPlayer.play(soundShieldLoss)
	else:
		pass
