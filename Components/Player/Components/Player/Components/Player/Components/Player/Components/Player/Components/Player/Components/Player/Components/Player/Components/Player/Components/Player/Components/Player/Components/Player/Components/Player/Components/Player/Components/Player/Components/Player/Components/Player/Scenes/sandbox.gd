extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Transition.openScene()
	#await LeaderboardApi.save("Jiri", 44)
	#await LeaderboardApi.save("Jiri", 29)

	var scores = await LeaderboardApi.top20()
	for score in scores:
		$Leaderboard.text += score.player + " => " + score.score + "\n"

