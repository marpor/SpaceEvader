extends "res://scripts/Breakable.gd"

var life = 1
var linear_velocity = Vector2.LEFT
var angular_velocity = 0

var SPEED = 150

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
	var ang = Helpers.randSpread(5)

	var dir = -Global.DIR.rotated(deg2rad(ang))

	var speed = SPEED * rand_range(0.7, 1.3) * Global.speedScale()
	linear_velocity = dir * speed

	# Rotate slightly
	angular_velocity = rand_range(-2, 2)

	# Random color tint
	var color = palette[randi()%palette.size()]
	for part in parts:
		part.modulate = color

func _on_VisibilityNotifier2D_screen_exited():
	removeMe()

func shot(source):
	# loose ALL parts
	while not parts.empty():
		var part = parts.pop_back()
#		call_deferred("loosePart", part, source)
		loosePart(part, source)

	life -= 1
	if (life == 0):
		Global.score += 1
		removeMe()

func _process(delta):
	if not Global.is_alive():
		return

	delta *= Global.speedOverride

	rotation += delta * angular_velocity
	position += delta * linear_velocity

func _physics_process(_delta):
	if (Global.CENTER - position).length() > Global.RADIUS*2:
		# VisibilityNotifier doesn't always fire
		removeMe()
