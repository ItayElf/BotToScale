extends CharacterBody2D
@export var speed: float = 10000
@onready var player = get_node("../Player")

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed * delta
	move_and_slide()
