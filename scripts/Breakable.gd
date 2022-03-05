# Base class for Enemy and Meteor
# Can break into fragments acting as shots
extends Area2D

var fragment = preload("res://misc/Shot.tscn")
onready var parent = get_node("/root")

func _ready():
	pass

# Override in derived classes. source is the object that hit us
func shot(source):
	pass

# Note: Must be called with call_deferred or similar. Direct calls from on_area_entered or similar will cause errors.
func loosePart(part, source):
	var pos = part.global_position
	var rot = part.global_rotation

	var old_parent = part.get_parent()
	old_parent.remove_child(part)

	# Weaponize part. Enables collision detecting etc.
	part.arm()

	Maps.currentMap.add_child(part)

	part.position = pos
	part.rotation = rot
	
	part.scale *= self.scale

	part.speed *= rand_range(0.5, 0.9) * Global.speedScale()
	if "dir" in source:
		part.dir = source.dir
	else:
		part.dir = Vector2.RIGHT

	var ang = Helpers.randSpread(35)
	part.rotate(deg2rad(ang))
	part.dir = part.dir.rotated(deg2rad(ang))
	part.angular_velocity = rand_range(-4, 4)
	part.visible = true

	part.sourceObject = self
	part.add_to_group("shots")

func collided_with_ship(source):
	# Explode when colliding with ship (that didn't die from the collision)
	while self.life > 0:
		self.shot(source)

func removeMe():
	$CollisionPolygon2D.set_deferred("disabled", true)
	visible = false
	queue_free()
