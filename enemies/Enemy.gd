extends "res://Breakable.gd"

var life = 1
var SPEED = 100

var palette1 = [
	Color("ee6055"),
	Color("60d394"),
	Color("aaf683"),
	Color("ffd97d"),
	Color("ff9b85"),
]

var palette = [
	Color("70D6FF"),
	Color("FF70A6"),
	Color("FF9770"),
	Color("FFD670"),
	Color("E9FF70"),
]

onready var parts = $Parts.get_children()

func _ready():
	position = Global.randStartPos(35)
	# Random color tint
#	modulate = Color.from_hsv(rand_range(0,1), .5, .75)
	var color = palette[randi()%palette.size()]

	scale = Vector2(0.75, 0.75)

	life = 0
	for part in parts:
		part.modulate = color

		life += 1

func shot(_body):
	life -= 1
	if (life == 0):
		Global.score += 25
		removeMe()

	var source = _body
	if not source:
		return

	# loose a part
	if not parts.empty():
		var part = parts.pop_back()
		$Parts.remove_child(part)

		call_deferred("loosePart", part, source)

func _process(delta):
	if not Global.alive:
		return

	var p0 = position
	var p1 = Global.player_pos
	var d = p1-p0
	var dir = d.normalized()
	var speed = SPEED * rand_range(0.7, 1.3) * Global.speedScale()
	rotation = dir.angle() - Vector2.DOWN.angle()

#	if d.length() < Global.RADIUS/2:
	position += dir * delta * speed

func _on_VisibilityNotifier2D_screen_exited():
	removeMe()
