extends "res://scripts/Breakable.gd"

export(int) var POINTS = 25
export(int) var SPEED = 100
export(bool) var HUNTS = true
export(Color) var COLOR = Color.white
export(float) var DIRECTION = 0
export(float) var ANGULAR_VELOCITY = 0
export(float) var TURN_RATE = 0

var life = 1

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

# Color("B34A36") # Orange
# Color("5E84A8") # Blue
# Color("A53333") # Red

onready var parts = $Parts.get_children()
onready var speed = SPEED
onready var dir = Vector2.DOWN.rotated(rotation + deg2rad(DIRECTION))

func setColorChildren(c, children):
	if c != Color.white:
		COLOR = c

		for part in children:
			if "color" in part:
				if part.Colored:
					part.color = COLOR
					part.updateModulate()
#			else:
#				part.modulate = COLOR

			# recurse
			setColorChildren(c, part.get_children())

func _ready():
	scale *= Vector2(0.75, 0.75)

	# Random color tint
#	modulate = Color.from_hsv(rand_range(0,1), .5, .75)
	if COLOR == Color.white:
		if get_parent() and get_parent().get_parent() and \
				get_parent().get_parent().get("EnemyColor"):
			COLOR = get_parent().get_parent().get("EnemyColor")
	if COLOR == Color.white:
		COLOR = palette[randi()%palette.size()]

	setColorChildren(COLOR, parts)

	# Add 1 life per part
	life = 0
	for part in parts:
		life += 1

func shot(source):
	# loose a part
	if not parts.empty():
		var part = parts.pop_back()
#		call_deferred("loosePart", part, source)
		loosePart(part, source)

	life -= 1
	if (life == 0):
		Global.score += POINTS

		var fadeOut = false
		if fadeOut:
			$CollisionPolygon2D.disabled = true

			var tween = Tween.new()
			var start_color = Color(1.0, 1.0, 1.0, 1.0)
			var end_color = Color(1.0, 1.0, 1.0, 0.0)
			add_child(tween)
			tween.interpolate_property(self, "modulate", start_color, end_color, .5)
			tween.interpolate_deferred_callback(self, .5, "removeMe")
			tween.start()
		else:
			removeMe()

func _process(delta):
	if not Global.is_alive():
		return

	delta *= Global.speedOverride

	var p0 = global_position
	if (p0-Global.CENTER).length() > Global.RADIUS*1.2:
		return

	if HUNTS:
		# Hunt player
		var p1 = Global.get_player_position()
		var d = p1-p0
		dir = d.normalized()
		rotation = dir.angle() - Vector2.DOWN.angle()
	else:
		rotation += deg2rad(ANGULAR_VELOCITY) * delta

		if TURN_RATE != 0.0:
			rotation += deg2rad(TURN_RATE) * delta
			dir = dir.rotated(deg2rad(TURN_RATE) * delta)

	position += dir * delta * speed * Global.speedScale()


func _on_VisibilityNotifier2D_screen_exited():
	# Enemies get cleared at map change, so we don't bother about it here
	# If we do clear them on screen exit, we risk clearing some when entering/leaving fullscreen
	pass
