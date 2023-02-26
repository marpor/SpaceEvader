tool
extends PanelContainer

export(String) var text = "Mission"
export(PackedScene) var map1 = null
export(PackedScene) var map2 = null
export(PackedScene) var map3 = null
export(Texture) var background = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBox/Label.text = text
	$VBox/HBox/Button1.visible = map1 != null
	$VBox/HBox/Button2.visible = map2 != null
	$VBox/HBox/Button3.visible = map3 != null

func _draw():
	if background:
		var bw = background.get_width()
		var bh = background.get_height()
		var baspect = bw/bh
		var daspect = rect_size.aspect()
		draw_texture_rect_region(background, 
			Rect2(rect_position, rect_size),
			Rect2(0,0, bw, bh))

func _on_Button1_pressed():
	Game.changeMap(map1.instance())

func _on_Button2_pressed():
	Game.changeMap(map2.instance())

func _on_Button3_pressed():
	Game.changeMap(map3.instance())

func _on_FreeplayButton_pressed():
	pass # Replace with function body.
