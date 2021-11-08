extends Area2D

var speed = 500
var dir = Vector2.RIGHT
var angular_velocity = 0
var sourceObject = null
var attached = true

func _ready():
	if attached:
		return

	Global.instanceCount+=1
	z_index = 5

func _exit_tree():
	if attached:
		return

	Global.instanceCount-=1
	queue_free()

func _process(delta):
	if attached:
		return

	if not Global.is_alive():
		return

	delta *= Global.speedOverride

	position += dir * speed * delta
	rotation += delta * angular_velocity

func _physics_process(_delta):
	if attached:
		return

	if (Global.CENTER - position).length() > Global.RADIUS*2:
		# VisibilityNotifier doesn't always fire
		_on_VisibilityNotifier2D_screen_exited()

func _on_Shot_body_entered(body):
	var target = body
	if target == self.sourceObject:
		return # Shot came from body - we don't want to "hit ourself"

	if self.position.x > Global.W or self.position.y > Global.H or self.position.y < 0:
		return # don't hit stuff off screen

	if target.has_method("shot"):
		#target.shot(self)
		target.call_deferred("shot", self)

#	if not piercingShot:
#		queue_free()

func _on_Shot_area_entered(area):
	_on_Shot_body_entered(area)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func arm():
	self.attached = false
	self.collision_layer = 16
	self.collision_mask = 96
	$colpol.disabled = false
	self.connect("area_entered", self, "_on_Shot_area_entered")
#	self.connect("body_entered", self, "_on_Shot_body_entered")
