extends Node2D

var paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Transition.openScene()
	init_floors()

func init_floors():
	for item in $Environment.get_children():
		item.get_node("CollisionPolygon2D").polygon = item.get_node("Polygon2D").polygon

func _input(event):
	if Input.is_key_pressed(KEY_R):
		Transition.switchTo("res://Scenes/Game.tscn")
