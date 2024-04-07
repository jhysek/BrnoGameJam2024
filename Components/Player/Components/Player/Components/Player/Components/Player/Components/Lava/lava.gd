extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	$Area/CollisionShape2D.shape.size = size
	$Area/CollisionShape2D.position = size / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_body_entered(body):
	if body.is_in_group("Player"):
		body.die()
