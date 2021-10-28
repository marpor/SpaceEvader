extends Area2D

var speed = 500
var dir
var angular_velocity = 0
var sourceObject = null

signal shot(source, target)

func _ready():
	Global.instanceCount+=1
	#dir = Global.DIR
	dir = Vector2.RIGHT
	rotate(dir.angle() - Vector2.UP.angle())
	var ship_tip = Global.player_pos + 30 * dir
	position = ship_tip
	z_index = 5

func _exit_tree():
	Global.instanceCount-=1

func _process(delta):
	if not Global.alive:
		return
	position += dir * speed * delta
	rotation += delta * angular_velocity

func _physics_process(_delta):
	if (Global.CENTER - position).length() > Global.RADIUS*2:
		# VisibilityNotifier doesn't always fire
		_on_VisibilityNotifier2D_screen_exited()

func _on_Shot_body_entered(body):
	var target = body
	if target == self.sourceObject:
		return # Shot came from body - we don't want to "hit ourself"

	if body.has_method("shot"):
		target = target.shot(self)
#		queue_free()

func emit(a,b,c):
	emit_signal(a,b,c)

func _on_Shot_area_entered(area):
	_on_Shot_body_entered(area)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Shot_area_exited(area):
#	emit_signal("shot", self, area)
	call_deferred("emit_signal", "shot", self, area)
