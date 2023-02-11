tool
extends EditorPlugin

const MainView: PackedScene = preload("main.tscn")
var view: Control

func _enter_tree():
	view = MainView.instance()
#	view.editor_interface = get_editor_interface()
	add_control_to_bottom_panel(view, "MapBuilder2")
	make_bottom_panel_item_visible(view)


func _exit_tree():
	remove_control_from_bottom_panel(view)
#	preview.editor_interface = null


