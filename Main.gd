extends Node2D
@onready var path_follow = $Path2D/PathFollow2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func spawn_enemy():
	var new_enemy = null
	var enemytype = -1
	match enemytype:
		1:
			new_enemy = preload("res://Characters/Enemies/enemy.tscn").instantiate()
		_:
			new_enemy = preload("res://Characters/Enemies/enemy.tscn").instantiate()
	path_follow.progress_ratio = randf()
	new_enemy.global_position = path_follow.global_position
	add_child(new_enemy)


func _on_timer_timeout():
	spawn_enemy()
