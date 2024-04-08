extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#$Area/CollisionShape2D.shape.size = size
	#$Area/CollisionShape2D.position = size / 2

func _on_area_body_entered(body):
	if body.is_in_group("Player"):
		body.die()

