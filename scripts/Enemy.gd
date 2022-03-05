# Enemy.gd - an enemy whose color, and behavior can be customized via exported
# properties.
# Scenes using this script *must* contain a Node2D named "Parts", and any
# children of this deriving from Part.gd adds to life, and each part (or 
# grouping of parts) can break of and act as shots when the enemy is hit.

extends "res://scripts/Breakable.gd"

# How many points to award player upon finishing enemy
export(int) var POINTS = 25
# Movement base speed.
export(int) var SPEED = 150
# If set, the enemy will fly towards the player ship.
export(bool) var HUNTS = true
# Start moving when player ship reaches this normalized U along map path.
export(float) var START_U = 0.0
# Color to use for any *Colored* parts.
export(Color) var COLOR = Color.white
# Fly in this direction (if HUNTS is false)
export(float) var DIRECTION = 0
# Spin around own axis. Degrees per second.
export(float) var ANGULAR_VELOCITY = 0
# Turn rate. Degrees per second. (if HUNTS is false)
export(float) var TURN_RATE = 0

# Life (each part will add 1 life)
var life = 1

# If color is not set (ie. White), pick a random color from this palette
var palette = [
	Color("70D6FF"),
	Color("FF70A6"),
	Color("FF9770"),
	Color("FFD670"),
	Color("E9FF70"),
]

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

			# recurse
			setColorChildren(c, part.get_children())

func _ready():
	scale *= Vector2(0.75, 0.75)

	# When no color specified:
	#  Get color from Get color from map "EnemyColor" property
	if COLOR == Color.white:
		if get_parent() and get_parent().get_parent() and \
				get_parent().get_parent().get("EnemyColor"):
			COLOR = get_parent().get_parent().get("EnemyColor")

	# No map color specified - grab a random color from palette
	if COLOR == Color.white:
		COLOR = palette[randi()%palette.size()]

	# Color all parts, recursively
	setColorChildren(COLOR, parts)

	# Add 1 life per part
	life = 0
	for part in parts:
		life += 1

# Note: Must be called with call_deferred or similar. Direct calls from on_area_entered or similar will cause errors.
func shot(source):
	# Loose a part
	if not parts.empty():
		var part = parts.pop_back()
		loosePart(part, source)

	life -= 1
	
	# Finished/killed enemy
	if (life == 0):
		# Add to score (respecting multipliers)
		var points = int(Global.score_multiplier * Global.score_extra_multiplier * POINTS)
		Global.score += points

		# Float score
		Game.float_text(global_position, points)
		
		# Update score multiplier
		if Global.use_multiplier:
			Global.score_multiplier *= 1.25
			if Global.score_multiplier > 8.0:
				Global.score_multiplier = 8.0
			Global.multiplier_timeout += 0.5
			if Global.multiplier_timeout > 2.0:
				Global.multiplier_timeout = 2.0

		# Fadeout and/or remove enemy
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

	Sounds.enemyHit(global_position, life)

func _process(delta):
	if not Global.is_alive():
		return

	delta *= Global.speedOverride * Global.speedScale()

	var p0 = global_position

	# Wait with moving until we reach (normalized) start time
	if Maps.currentMap.u < START_U:
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

	position += dir * delta * speed

func _on_VisibilityNotifier2D_screen_exited():
	# Enemies get cleared at map change, so we don't bother about it here
	# If we do clear them on screen exit, we risk clearing some when entering/leaving fullscreen
	pass
