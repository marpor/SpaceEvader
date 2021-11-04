extends Node2D

var streak = preload("res://misc/Streak.tscn")
var streaks = []

func _ready():
	for n in 16:
		var s = streak.instance()
		s.show()
		streaks.append(s)
		self.add_child(s)
