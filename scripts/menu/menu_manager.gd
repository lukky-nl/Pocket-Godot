extends Control

@onready var main_menu:Control = $menu_margin/main_menu
@onready var about:Control = $menu_margin/about

 
func _on_fps_demo_button_pressed():
	get_tree().change_scene_to_file("res://scenes/demos/first_person_demo.tscn")


func _on_tp_demo_button_pressed():
	get_tree().change_scene_to_file("res://scenes/demos/third_person_demo.tscn")


func _on_td_demo_button_pressed():
	get_tree().change_scene_to_file("res://scenes/demos/top_down_demo.tscn")


func _on_about_button_pressed():
	main_menu.hide()
	about.show()


func _on_back_button_pressed():
	main_menu.show()
	about.hide()
