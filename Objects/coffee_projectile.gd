extends Area2D

var is_players : bool
var speed : float
var direction : Vector2
var damage : float

func initialize(_is_players, _speed, _direction, _damage):
	is_players = _is_players
	speed = _speed
	direction = _direction
	damage = _damage

func _physics_process(delta):
	position += direction * speed * delta


func _on_body_entered(body):
	if body is TileMap or body.get_collision_layer_value(1):
		queue_free()
	elif body.get_collision_layer_value(2):
		if is_players:
			body.get_hit(damage)
			queue_free()
	elif body.get_collision_layer_value(3):
		if not is_players:
			body.add_health(-damage)
			queue_free()
	elif body.get_collision_layer_value(7):
		if not is_players:
			body.add_health(-damage)
			queue_free()
	
