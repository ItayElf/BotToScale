extends CharacterBody2D
@export var speed = 250 ##we will change it later
@onready var player = get_node("../Player") ##finds player

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position) ##gets the direction
	position += direction * speed * delta ##moves enemy
	look_at(player.global_position) ##looks at player
	move_and_slide()



