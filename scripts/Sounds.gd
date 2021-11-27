extends Node

var players: Array
var nextPlayer = 0

func _init():
	for n in range(10):
		var player = AudioStreamPlayer.new()
		players.append(player)
		self.add_child(player)

func play(pos, sound):
	var player: AudioStreamPlayer = players[nextPlayer]
	nextPlayer += 1
	if nextPlayer >= players.size():
		nextPlayer = 0

	# Scale from 100px from ship
	var distance = (pos - Global.ship.global_position).length() - 100
	if distance < 0:
		distance = 0
	var scale = (distance/(Global.RADIUS*2))
	var vol = scale * -40 # approx half volume across screen

	player.stream = sound
	player.volume_db = vol
	player.pitch_scale = 1.0-scale
	player.play()

var soundShot = preload("res://sounds/shot2.wav")
func shot(pos):
	play(pos, soundShot)

var soundMeteorHit = preload("res://sounds/meteor1.wav")
var soundMeteorDied = preload("res://sounds/enemyhit2.wav")

func meteorHit(pos, life):
	if life > 0:
		play(pos, soundMeteorHit)
	else:
		play(pos, soundMeteorDied)

var soundEnemyHit = preload("res://sounds/metal1.wav")
var soundEnemyDied = preload("res://sounds/metal2.wav")

func enemyHit(pos, life):
	if life > 0:
		play(pos, soundEnemyHit)
	else:
		play(pos, soundEnemyDied)

var soundShield = preload("res://sounds/shield3.wav")

func shield(pos):
	play(pos, soundShield)

var soundShieldLoss = preload("res://sounds/shieldloss2.wav")
func playerHit(pos, health):
	if health > 0:
		play(pos, soundShieldLoss)
	else:
		pass
