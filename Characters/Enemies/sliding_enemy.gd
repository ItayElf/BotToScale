extends CharacterBody2D
@export var health: float = 100
@export var speed: float = 1500
@export var acceleration: float = 100
@onready var player = get_node("../Player")

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = velocity.move_toward(direction * speed, acceleration * delta)
	move_and_slide()

