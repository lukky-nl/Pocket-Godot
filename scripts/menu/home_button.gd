extends TextureButton

func _pressed():
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
