extends Node

# A looping audio player.

var player: AudioStreamPlayer = null
var from_position = 0.0
var volume = 0.0

func _init():
	player = AudioStreamPlayer.new()
	player.connect("finished", self, "replay")
	self.add_child(player)

func volume_changed(volume):
	self.volume = volume
	player.volume_db = volume

func play(sound, volume_db = 0):
	player.stream = sound
	player.volume_db = volume + volume_db
	player.play()

func replay():
	player.volume_db = volume
	player.play(from_position)
