extends CharacterBody2D
@export var speed = 100
var player_pos
var direction
@onready var player = get_node("../Player")

func _physics_process(delta):
	player_pos = player.global_position
	direction= global_position.direction_to(player_pos)
	position += direction * speed * delta
	look_at(player_pos)
	move_and_slide()
