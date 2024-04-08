extends Area2D

signal on_hit

var attacking = false
var swinged = false
var in_air = false

func attack():
	attacking = true
	for area in get_overlapping_areas():
		if area.is_in_group("Enemy"):
			area.get_parent().hit()

func swing():
	swinged = true

func attack_done():
	attacking = false
	swinged = false

func hit():
	emit_signal("on_hit")
