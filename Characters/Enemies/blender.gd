class_name Blender
extends Enemy

@export var damage : int = 1

var is_player_here = false
var can_attack = true


@onready var cooldown_timer = $"Attack Cooldown"
@onready var animation_tree = $AnimationTree

func _ready():
	enemy_init()
	if randf() > 0.5:
		go_for_station()
	else:
		go_for_player()

func go_for_player():
	is_following_player = true
	if get_tree().get_first_node_in_group("player"):
		player = get_tree().get_first_node_in_group("player")
		current_target = player

func go_for_station():
	var choices = get_tree().get_nodes_in_group("station")
	if choices.size() > 1:
		if randf() > 0.5:
			player = choices[0]
		else:
			player = choices[1]
	elif choices.size() == 0:
		player = get_tree().get_first_node_in_group("station")
	else:
		go_for_player()
		return
	current_target = player
	is_following_player = false

func _process(delta):
	if current_target != null:	
		animation_tree.set("parameters/conditions/is_idle", false)
		animation_tree.set("parameters/conditions/is_moving", true)
		animation_tree.set("parameters/Idle/blend_position", input)
		animation_tree.set("parameters/Move/blend_position", input)
		
		if $Roomba/Sprite.flip_h and input.x > 0 or not $Roomba/Sprite.flip_h and input.x < 0:
			var opposite = not $Roomba/Sprite.flip_h
			$Roomba/Sprite.flip_h = opposite
			$Blender/Sprite.flip_h = opposite
			$Coffee/Sprite.flip_h = opposite
			$Refrigerator/Sprite.flip_h = opposite
			$Fan/Sprite.flip_h = opposite
	else:
		animation_tree.set("parameters/conditions/is_idle", true)
		animation_tree.set("parameters/conditions/is_moving", false)
	

func _on_attack_trigger_body_entered(body):
	if not can_attack: return
	
	is_player_here = true
	
	attack()

func _on_attack_trigger_body_exited(body):
	is_player_here = false

func attack():
	if player == null:
		if get_tree().get_first_node_in_group("player") != null:
			print("her")
			get_tree().get_first_node_in_group("player").add_health(-damage)
	else:
		player.add_health(-damage)
	can_attack = false
	cooldown_timer.start()
	MusicController.p_attack_slice()

func _on_attack_cooldown_timeout():
	if is_player_here:
		attack()
	else:
		can_attack = true
