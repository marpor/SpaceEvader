# Base class for Enemy and Meteor
# Can break into fragments acting as shots
extends Area2D

var fragment = preload("res://misc/Shot.tscn")
onready var parent = get_node("/root")

func _ready():
	pass

func looseIt(s, source):
	s.scale *= self.scale

	s.speed *= rand_range(0.5, 0.9) * Global.speedScale()
	if "dir" in source:
		s.dir = source.dir
	else:
		s.dir = Vector2.RIGHT

	var ang = Helpers.randSpread(35)
	s.rotate(deg2rad(ang))
	s.dir = s.dir.rotated(deg2rad(ang))
	s.angular_velocity = rand_range(-4, 4)
	s.visible = true

	s.sourceObject = self
	s.add_to_group("shots")

func looseSpritePart(sprite, source):
	# For enemies built with sprites
	var s = fragment.instance()

	# Replace sprite with that from part
	var newSprite = s.get_node("Sprite")
	newSprite.texture = sprite.texture
	newSprite.modulate = sprite.modulate
	newSprite.scale = sprite.scale

	# Remove old part
	var old_parent = sprite.get_parent()
	old_parent.remove_child(sprite)
	sprite.free()

	parent.add_child(s) # gives error when called during on_area_entered or similar - need call_deferred
	s.position = source.position
	s.attached = false
	looseIt(s, source)

func loosePart(part, source):
	var s = part

	if s is Sprite:
		looseSpritePart(part, source)
		return

	# For enemies built with parts (Area2D)

#	part.free()
	var old_parent = part.get_parent()
	var pos = part.global_position
	var rot = part.global_rotation
#	part.owner = parent
	old_parent.remove_child(part)
#	parent.add_child(part)
	#part.free()

	s.arm()
#	s.script = preload("res://scripts/Shot.gd")

	Maps.currentMap.add_child(s) # gives error when called during on_area_entered or similar - need call_deferred

	s.position = pos
	s.rotation = rot
	looseIt(s, source)

func shot(source):
	# Override in derived classes
	pass

func collided_with_ship(source):
	# Explode when colliding with ship (that didn't die from the collision)
	while self.life > 0:
		self.shot(source)

func removeMe():
	$CollisionPolygon2D.set_deferred("disabled", true)
	visible = false
#	yield(get_tree().create_timer(0.1), "timeout")
	queue_free()
