extends Node2D

# A polyPponic audio player. Can play multiple sounds simultaneously

var players: Array
var nextPlayer = 0

func _init(var polyCount=1, busname="Master"):
	for n in range(polyCount):
		var player = AudioStreamPlayer.new()
		player.bus = busname
		players.append(player)
		self.add_child(player)

func get_player():
	var player: AudioStreamPlayer = players[nextPlayer]
	nextPlayer += 1
	if nextPlayer >= players.size():
		nextPlayer = 0
	return player

func play(sound, volume_db=0.0, pitch_scale=1.0):
	var player = get_player()
	
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale

	player.stream = sound
	player.play()

func play_distanced(position, sound):
	# Scale from 100px from ship
	var distance = (position - Global.ship.global_position).length() - 100
	if distance < 0:
		distance = 0
	var scale = (distance/(Global.RADIUS*2))
	var vol = scale * -40 # how many db to lower volume across screen

	play(sound, vol, 1.0-scale)
