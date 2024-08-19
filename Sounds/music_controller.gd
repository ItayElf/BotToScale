extends Node
#
### This script is responsible for playing music. The node it's attached
### to can be accessed globally using `MusicController.play_effect(...)`
#
#const _LOWER_VOLUME := 10.0
#
#var _last_played: AudioStream = null
#
#@onready var background_player: AudioStreamPlayer = $BackgroundMusic
#@onready var effects_player: AudioStreamPlayer = $EffectsPlayer
#
### This function plays background music. 
### It assumes that the given stream is looping (check import panel).
### You need to load the file using `preload` or `load` and then pass them to 
### this function.
#func play_music(stream: AudioStream):
	#if stream == _last_played:
		#return
	#_last_played = stream
	#background_player.stream = stream
	#background_player.play()
#
#
### This function stops the currently played background music.
#func stop_music():
	#background_player.stop()
	#_last_played = null
#
#
###This function plays sound effects. 
### It lowers the volume of the background music, plays the sound effect and 
### then when the effect finishes it raises the volume to its original volume.
### You need to load the file using `preload` or `load` and then pass them to 
### this function.
#func play_sound_effect(stream: AudioStream):
	#background_player.volume_db -= _LOWER_VOLUME
	#effects_player.stream = stream
	#effects_player.play()
	#await effects_player.finished
	#background_player.volume_db += _LOWER_VOLUME

func p_pickup():
	$Pickup.play()

func p_metal_footstep():
	$MetalFootstep.play()

func p_hit():
	$Hit.play()

func p_game_over():
	$GameOver.play()

func p_fridge_footstep():
	$FridgeFootstep.play()

func p_transition_down():
	$TransitionDown.play()

func p_transition_up():
	$TransitionUp.play()

func p_attack_slice():
	$AttackSlice.play()

func p_metallic():
	$Metallic.play()

func p_loop_blender():
	$_LoopBlender.play()
func s_loop_blender():
	$_LoopBlender.stop()

func p_loop_robot_suck():
	$_LoopRobotSuck.play()
func s_loop_robot_suck():
	$_LoopRobotSuck.stop()
