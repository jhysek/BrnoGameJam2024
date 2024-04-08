extends Node2D

var paused = false

var start_time = 0
var stop_time = 0
var kills = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Transition.openScene()

func _process(delta):
	if start_time > 0 and stop_time == 0:
		update_time()

func _input(event):
	if !paused and Input.is_key_pressed(KEY_R):
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
	restart_level()

func _on_exit_exit_reached():
	stop_time = Time.get_unix_time_from_system()
	update_time()
	$UI/Panel/Time.text = "Finished in " + $UI/Time.text
	$UI/AnimationPlayer.play("ShowResult")
	$UI/Panel/Results.hide()
	$UI/Panel/Again.hide()
	paused = true


func _on_again_pressed():
	if $UI/Panel/Again.visible:
		restart_level()


func _on_save_pressed():
	var name = $UI/Panel/TextEdit.text
	if name == "":
		name = "anonymous"
	await LeaderboardApi.save(name, int(stop_time - start_time))
	var results = await LeaderboardApi.top5()
	update_results(results)
	$UI/Panel/Timer.start()

func update_results(results):
	$UI/Panel/Save.hide()
	$UI/Panel/TextEdit.hide()
	$UI/Panel/Label2.hide()
	var res = ""
	for item in results:
		res += item.score + " \t " + item.player + " \n"
	$UI/Panel/Results.text = "TOP 5:\n\n" + res
	$UI/Panel/Results.show()
	$UI/Panel/Again.show()

func _on_timer_timeout():
	var results = await LeaderboardApi.top5()
	update_results(results)

func _on_player_killed():
	kills += 1
	$UI/Kills.text = str(kills)

func _on_horse_killed():
	kills += 1
	$UI/Kills.text = str(kills)
