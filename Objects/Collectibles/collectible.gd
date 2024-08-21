class_name Collectible
extends Area2D

@export var sprites: Array[Resource] = []
@export var heal_amount: float = 1

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D

func _ready():
	_sprite.frame = randi_range(0, _sprite.hframes-1)


func _on_body_entered(body):
	if body is Player:
		body.add_health(heal_amount)
		queue_free()
	elif body is Roomba:
		body.collect_part()
		queue_free()
	
