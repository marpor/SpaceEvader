extends Node

# A looping audio player.

var player: AudioStreamPlayer = null
var from_position = 0.0

func _init():
	player = AudioStreamPlayer.new()
	player.connect("finished", self, "replay")
	self.add_child(player)

func play(sound, volume_db=0.0):
	player.stream = sound
	player.volume_db = volume_db
	player.play()

func replay():
	player.play(from_position)
