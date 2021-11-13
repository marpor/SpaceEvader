extends Node2D

var moving = false

func _ready():
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")

	Global.ship.health = 2
	Global.ship.health_changed(Global.ship.health)

	Maps.currentMap = self

	$Heic2007a.visible = false

	# Square
	yield(screenshot2("res://export/Icon120x120.png",120,120), "completed")
	yield(screenshot2("res://export/Icon76x76.png",76,76), "completed")
	yield(screenshot2("res://export/Icon1024x1024.png",1024,1024), "completed")

	$Heic2007a.visible = true

	# Landscape
	yield(screenshot2("res://export/iphone_2436x1125.png",2436,1125), "completed")
	yield(screenshot2("res://export/iphone_2208x1242.png",2208,1242), "completed")
	yield(screenshot2("res://export/iphone_2436x1125.png",2436,1125), "completed")
	yield(screenshot2("res://export/ipad_1024x768.png",1024, 768), "completed")
	yield(screenshot2("res://export/ipad_2048x1536.png",2048,1536), "completed")

	# Portrait
	yield(screenshot2("res://export/iphone_640x960.png",640,960), "completed")
	yield(screenshot2("res://export/iphone_640x1136.png",640,1136), "completed")
	yield(screenshot2("res://export/iphone_750x1334.png",750,1334), "completed")
	yield(screenshot2("res://export/iphone_1125x2436.png",1125,2436), "completed")
	yield(screenshot2("res://export/ipad_768x1024.png",768,1024), "completed")
	yield(screenshot2("res://export/ipad_1536x2048.png",1536,2048), "completed")
	yield(screenshot2("res://export/iphone_1242x2208.png",1242,2208), "completed")

	get_tree().quit()

func _on_viewport_size_changed():
	# Do whatever you need to do when the window changes!
	print ("Viewport size changed to ", get_viewport().size)

func set_size(w,h):
	if w != 0:
		OS.set_window_size(Vector2(w,h))

		if w > h:
			position.x = (float(w)/h - 1.0) * 720/2
		else:
			position.y = (float(h)/w - 1.0) * 720/2

	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	get_viewport().set_transparent_background(true)

func screenshot(filename, w=0, h=0):
	# Retrieve the captured image.
	var img = get_viewport().get_texture().get_data()

	# Flip it on the y-axis (because it's flipped).
	img.flip_y()

	# Crop - needed for odd sizes (e.g. for w=1125 get_data returns 1126 wide
	img.crop(w,h)

	img.save_png(filename)

func screenshot2(filename, w,h):
	set_size(w,h)
	yield(VisualServer, "frame_post_draw")
	screenshot(filename, w,h)
