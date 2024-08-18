class_name Enemy
extends CharacterBody2D

@export var max_health: float = 100
@export var speed: float = 340.
@export var acceleration: float = 500.0
@export var knockback_multiplier = 1.0

var is_navigation_ready = false
var current_target
var player
var health:
	set = set_health

@onready var health_bar : ProgressBar = $"Health Bar"
@onready var navigation : NavigationAgent2D = $NavigationAgent2D

func _ready():
	enemy_init()

func enemy_init():
	player = get_tree().get_first_node_in_group("player")
	health = max_health
	
	current_target = player

	# Magic code from the documentation
	navigation.path_desired_distance = 4.0
	navigation.target_desired_distance = 4.0
	
	call_deferred("actor_setup")

func _physics_process(delta):
	if is_navigation_ready and current_target != null:
		if not navigation.is_navigation_finished():
			var direction = global_position.direction_to(navigation.get_next_path_position())
			velocity = velocity.move_toward(direction * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
	move_and_slide()

func get_hit(dmg):
	health -= dmg
	if health <= 0:
		queue_free()

func set_health(value):
	health = value
	health_bar.value = health / max_health
	

func actor_setup():
	await get_tree().physics_frame
	is_navigation_ready = true
	if current_target != null:
		navigation.target_position = current_target.position


func _on_navigation_refresh_timeout():
	if current_target != null:
		navigation.target_position = current_target.position
