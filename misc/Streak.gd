extends Node2D

var SPEED = 500

# Called when the node enters the scene tree for the first time.
func _ready():
	start()

func start():
	position = Global.randStartPos(45) + Global.DIR * rand_range(0, Global.RADIUS*2)

func _process(delta):
	var dir = Vector2.RIGHT #Global.DIR
	rotation = dir.angle()
	position += delta * Global.speedScale() * SPEED * -dir

func _physics_process(_delta):
	if (Global.CENTER - position).length() > Global.RADIUS*3.1:
		# VisibilityNotifier doesn't always fire
		_on_VisibilityNotifier2D_screen_exited()

func _on_VisibilityNotifier2D_screen_exited():
	if Global.moving:
		start()
