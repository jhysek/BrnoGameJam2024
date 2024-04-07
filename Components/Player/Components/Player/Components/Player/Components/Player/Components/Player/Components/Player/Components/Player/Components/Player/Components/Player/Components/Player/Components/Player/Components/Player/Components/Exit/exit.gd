extends Sprite2D

signal exit_reached

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("exit_reached")
