tool
extends Area2D

var color = Color.white

export(bool) var Colored = false setget set_colored
func set_colored(val):
	Colored = val
	updateModulate()

export(bool) var Darkened = false setget set_darkened
func set_darkened(val):
	Darkened = val
	updateModulate()

func updateModulate():
	var mod = color
	if Colored:
		if mod == Color.white:
			mod = Color.from_hsv(.3, .5, 1.0)
	if Darkened:
		mod.v *= 0.85
	$sprite.modulate = mod

export(bool) var FlipH  = false setget set_flip_h
func set_flip_h(val):
	FlipH = val
	$sprite.flip_h = val

export(bool) var FlipV = false setget set_flip_v
func set_flip_v(val):
	FlipV = val
	$sprite.flip_v = val

export(int) var ScaleFactor = 4 setget set_scale
func set_scale(val):
	ScaleFactor = val
	$sprite.scale = Vector2(1.0/val, 1.0/val)
