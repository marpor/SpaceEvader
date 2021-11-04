extends Node2D

var SPEED = 500
var dir = Vector2.RIGHT

func _ready():
	start()

func start():
	dir = Global.DIR
	global_position = Global.randStartPos(45) + dir * rand_range(0, Global.RADIUS*2)

func _process(delta):
	if not Maps.currentMap or not Maps.currentMap.moving:
		return

	dir = Global.DIR
#	delta *= Global.speedOverride
	rotation = dir.angle()
	global_position += delta * Global.speedScale() * SPEED * -dir

func _physics_process(_delta):
	if (Global.CENTER - position).length() > Global.RADIUS*3.1:
		# VisibilityNotifier doesn't always fire
		_on_VisibilityNotifier2D_screen_exited()

func _on_VisibilityNotifier2D_screen_exited():
	if Maps.currentMap.moving:
		start()
