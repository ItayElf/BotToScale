extends StaticBody2D

@export var max_health = 500.0

var current_health : float

@onready var health_bar = $"Health Bar"

func _ready():
	current_health = max_health
	update_health_bar(current_health/max_health)

func add_health(amount):
	if amount < 0:
		MusicController.p_hit()
		current_health += amount
		if name.begins_with("A"):
			if get_tree().get_first_node_in_group("player"):
				get_tree().get_first_node_in_group("player").A_update(current_health/max_health)
		if name.begins_with("B"):
			if get_tree().get_first_node_in_group("player"):
				get_tree().get_first_node_in_group("player").B_update(current_health/max_health)
		if current_health <= 0:
			queue_free()
	
		update_health_bar(current_health/max_health)

func update_health_bar(percent):
	health_bar.value = percent
