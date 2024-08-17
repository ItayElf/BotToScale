extends Node

@export var sprites: Array[Resource] = []

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D

func _ready():
	_sprite.texture = sprites.pick_random()

func _on_body_entered(body):
	if body is Player:
		print("test")
