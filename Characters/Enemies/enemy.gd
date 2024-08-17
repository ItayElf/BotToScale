class_name Enemy
extends CharacterBody2D

@export var max_health: float = 100
@export var speed: float = 340.
@export var acceleration: float = 500.0

var player
var health:
	set = set_health

@onready var health_bar = $"Health Bar"

func _ready():
	player = get_tree().get_first_node_in_group("player")
	health = max_health

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = velocity.move_toward(direction * speed, acceleration * delta)
	move_and_slide()

func get_hit(dmg):
	health -= dmg
	if health <= 0:
		queue_free()

func set_health(value):
	health = value
	health_bar.value = health / max_health
	
