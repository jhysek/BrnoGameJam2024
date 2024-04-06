extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func hit():
	var splash = $BloodSplash
	splash.reparent(get_parent())
	splash.emitting = true
	queue_free()

func _on_hitbox_area_entered(area):
	if area.is_in_group("Weapon") and area.attacking:
		hit()
