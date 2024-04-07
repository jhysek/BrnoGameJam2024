extends Node2D

var paused = false

var start_time = 0
var stop_time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Transition.openScene()

func _process(delta):
	if start_time > 0 and stop_time == 0:
		update_time()

func _input(event):
	if Input.is_key_pressed(KEY_R):
		restart_level()

func restart_level():
	Transition.switchTo("res://Scenes/Game.tscn")

func _on_player_level_started():
	start_time = Time.get_unix_time_from_system()

func update_time():
	var time = Time.get_unix_time_from_system()
	var minutes = "%02d" % [floor(time - start_time) / 60]
	var seconds = "%02d" % [ int(time - start_time) % 60 ]
	$UI/Time.text = str(minutes) + ":" + str(seconds)

func _on_player_died():
	print("DEAD!")
	restart_level()

func _on_exit_exit_reached():
	stop_time = Time.get_unix_time_from_system()
	update_time()
	print("FINISHED")
