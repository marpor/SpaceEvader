extends Area2D

var life = 1
var linear_velocity = Vector2.LEFT
var angular_velocity = 0

var SPEED = 150

var fragmentTextures = []

var palette1 = [
	Color("D8C9BE"), # lt brownish
	Color("BB9E92"), # dk brownish
	Color("D7C782"), # goldish
	Color("ffffff"), # white
]

var palette2 = [
	Color("ffedd8"),
	Color("f3d5b5"),
	Color("e7bc91"),
	Color("d4a276"),
	Color("bc8a5f"),
]

# https://coolors.co/6b9080-a4c3b2-cce3de-eaf4f4-f6fff8
var palette = [
	Color("6B9080"),
	Color("A4C3B2"),
	Color("CCE3DE"),
	Color("EAF4F4"),
	Color("F6FFF8"),
]

onready var parts = $Parts.get_children()

func _ready():
	for part in parts:
		fragmentTextures.append(part.texture)

	var ang = Global.randSpread(5)

	position = Global.randStartPos()
	var dir = -Global.DIR.rotated(deg2rad(ang))

	var speed = SPEED * rand_range(0.7, 1.3) * Global.speedScale()
	linear_velocity = dir * speed

	# Rotate slightly
	angular_velocity = rand_range(-2, 2)

	# Random color tint
	modulate = palette[randi()%palette.size()]


func _on_VisibilityNotifier2D_screen_exited():
#	Global.score += 1
	queue_free()

func shot(_body):
	life -= 1
	if (life == 0):
		Global.score += 1
		$CollisionPolygon2D.set_deferred("disabled", true)
#		queue_free()
#		$AnimationPlayer.play("die")
		yield(get_tree().create_timer(0.1), "timeout")
		queue_free()

func _process(delta):
	if not Global.alive:
		return

	rotation += delta * angular_velocity
	position += delta * linear_velocity

func _physics_process(_delta):
	if (Global.CENTER - position).length() > Global.RADIUS*2:
		# VisibilityNotifier doesn't always fire
		_on_VisibilityNotifier2D_screen_exited()
