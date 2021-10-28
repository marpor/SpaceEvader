extends Node
# This will track the position of every pointer in its public `state` property, which is a
# Dictionary, in which each key is a pointer index (integer) and each value its position (Vector2).
# It works by listening to input events not handled by other means.
# It also remaps the pointer indices coming from the OS to the lowest available to be friendlier.
# It can be conveniently setup as a singleton.

signal TouchStateEvent(event, state)

class State:
	var origin = Vector2()
	var position = Vector2()

	func get_relative(maxLength = 0):
		var d = position - origin
		if maxLength > 0:
			if d.length() > maxLength:
				return d.normalized() * maxLength
		return d

var state = {}

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.index == 0:
			return # not a multi-touch event
		if event.pressed: # Down.
			var s = State.new()
			s.origin = event.position
			s.position = s.origin
			state[event.index] = s
			emit_signal("TouchStateEvent", event, s)
		else: # Up.
			state.erase(event.index)
			emit_signal("TouchStateEvent", event, null)
#		get_tree().set_input_as_handled()

	elif event is InputEventScreenDrag: # Movement.
		if event.index == 0:
			return # not a multi-touch event
		var s = state[event.index]
		s.position = event.position
		emit_signal("TouchStateEvent", event, s)
#		get_tree().set_input_as_handled()
