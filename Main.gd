extends Node2D
@onready var path_follow = $Spawner/PathFollow2D
@export var time = 2
@export var timemulti:float= 1

func spawn_enemy():
	var new_enemy = null
	var enemytype = 2#randi_range(0, 4)
	match enemytype:
		0:
			new_enemy = preload("res://Objects/Collectibles/collectible.tscn").instantiate()
		1:
			new_enemy = preload("res://Characters/Enemies/roomba.tscn").instantiate()
		2:
			new_enemy = preload("res://Characters/Enemies/blender.tscn").instantiate()
		3:
			new_enemy = preload("res://Characters/Enemies/coffee.tscn").instantiate()
		4:
			new_enemy = preload("res://Characters/Enemies/refrigerator.tscn").instantiate()
	path_follow.progress_ratio = randf()
	new_enemy.global_position = path_follow.global_position
	add_child(new_enemy)


func _on_timer_timeout():
	spawn_enemy()
	timemulti -= 0.003
	time *= timemulti
	if time<0.2:
		$Timer.wait_time = 0.2
	else:
		$Timer.wait_time = time
	print(time)
