# Base class for Enemy and Meteor
# Can break into fragments acting as shots
extends Area2D

var fragment = preload("res://misc/Shot.tscn")

func _ready():
	pass

func loosePart(part, source):
	var ang = Helpers.randSpread(35)

	var s = fragment.instance()

	# Replace sprite with that from part
	var sprite = s.get_node("Sprite")
	if not "texture" in part:
		part = part.get_node("sprite")
	sprite.texture = part.texture
	sprite.modulate = part.modulate
	sprite.scale = part.scale

	s.scale = self.scale

	var parent = get_node("/root")
	parent.add_child(s) # gives error when called during on_area_entered or similar - need call_deferred

	s.speed *= rand_range(0.5, 0.9)
	if "dir" in source:
		s.dir = source.dir
	else:
		s.dir = Vector2.RIGHT
	s.position = source.position

	s.rotate(deg2rad(ang))
	s.dir = s.dir.rotated(deg2rad(ang))
	s.angular_velocity = rand_range(-4, 4)
	s.visible = true

	s.sourceObject = self

func removeMe():
	$CollisionPolygon2D.set_deferred("disabled", true)
	visible = false
#	yield(get_tree().create_timer(0.1), "timeout")
	queue_free()
