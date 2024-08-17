extends Control



func _on_button_pressed():
	change_scene()
func change_scene():
	get_tree().change_scene_to_file("res://story.tscn")


func _on_button_2_pressed():
	get_tree().quit()
