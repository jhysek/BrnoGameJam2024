extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Transition.openScene()

func _on_button_pressed():
	Transition.switchTo("res://Scenes/Game.tscn")
