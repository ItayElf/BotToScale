extends CanvasLayer
var time: int = 0
func update_health_bar(percentage : float):
	$Health/HealthBar.value = percentage
func handle_death():
	$Game_over.visible = true
	$Health.visible = false
	$ColorRect.visible = true
	$ColorRect2.visible = true
	if GlobalHighScore.besttime< time:
		GlobalHighScore.besttime = time
	
	$Game_over/VBoxContainer2/Label4.text =  "Score :" + str(time)
	$Game_over/VBoxContainer2/Label3.text =  "High Score :" + str(GlobalHighScore.besttime)

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Main.tscn")


func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://ui/mainmenu/main_menu.tscn")


func _on_timer_timeout():
	time +=1
