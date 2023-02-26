extends Node2D

func dir_contents(path):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.get_extension() == 'tscn':
				print("Found scene: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")


# Called when the node enters the scene tree for the first time.
func _ready():
	dir_contents("res://maps")
	
	for map in Maps.maps:
		print(map.instance().Location)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

