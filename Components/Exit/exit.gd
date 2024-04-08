extends Sprite2D

signal exit_reached
var reached = false

func _on_area_2d_body_entered(body):
	if !reached and body.is_in_group("Player"):
		reached = true
		emit_signal("exit_reached")
