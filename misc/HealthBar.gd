extends HBoxContainer

var filled = preload("res://artwork/Heart.png")
var outline = preload("res://artwork/HeartOutline.png")

func _ready():
	pass # Replace with function body.

func update_life(value):
	for i in get_child_count():
		if value > i:
			get_child(i).texture = filled
		else:
			get_child(i).texture = outline
