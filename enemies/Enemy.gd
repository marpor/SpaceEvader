extends Area2D

var fragment = preload("res://enemies/Fragment.tscn")

var life = 1
var SPEED = 100

var fragmentTextures = []

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
#		fragmentTextures.append(part.texture)

		life += 1

func shot(_body):
	life -= 1
	if (life == 0):
		Global.score += 25
		$CollisionPolygon2D.set_deferred("disabled", true)
		visible = false
#		call_deferred("queue_free")
		yield(get_tree().create_timer(0.1), "timeout")
		queue_free()


	var source = _body
	if not source:
		return

	# loose a part
	if not parts.empty():
		var part = parts.pop_back()
		$Parts.remove_child(part)

		var ang = Global.randSpread(35)

		var s = fragment.instance()
		var sprite = s.get_node("Sprite")
		sprite.texture = part.texture
		sprite.modulate = part.modulate
		sprite.scale = part.scale
		part.queue_free()

		s.scale = self.scale

		var parent = get_node("/root/Main")
		parent.add_child(s)

		s.speed *= rand_range(0.5, 0.9)
		s.dir = source.dir
		s.position = source.position
		s.rotate(deg2rad(ang))
		s.dir = s.dir.rotated(deg2rad(ang))
		s.angular_velocity = rand_range(-4, 4)
		s.visible = true

		s.sourceObject = self


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
	queue_free()
