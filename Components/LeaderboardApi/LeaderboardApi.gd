extends Node

func _ready():
	SilentWolf.configure({
		"api_key": "cwLLnCR3yq2E89wUcXqYE3G3HG0fbL4H1ODN0WTz",
		"game_id": "TurboJost1",
		"log_level": 1
	})

func top5():
	var result = []
	var response: Dictionary = await SilentWolf.Scores.get_scores(5).sw_get_scores_complete
	for score in response.scores:
		result.append({
			player  = score.player_name,
			score = format_time(_score_to_seconds(score.score))
		})
	return result

func save(player_name: String, seconds: int):
	SilentWolf.Scores.save_score(player_name, _seconds_to_score(seconds))

func _seconds_to_score(seconds: int):
	return 10000 - seconds

func _score_to_seconds(score: int):
	return 10000 - score

func format_time(time: int):
	var minutes = "%02d" % [time / 60]
	var seconds = "%02d" % [time % 60]
	return minutes + ":" + seconds
