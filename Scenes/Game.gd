extends Node2D

var paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	init_floors()

func init_floors():
	for item in $Environment.get_children():
		item.get_node("CollisionPolygon2D").polygon = item.get_node("Polygon2D").polygon
