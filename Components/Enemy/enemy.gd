extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var path = []
var target_idx = 0
var target
var direction = Vector2.LEFT
var dead = false
var walking = true

const SPEED = 10000

@onready var anim = $AnimationPlayer

func _ready():
	$Timer.wait_time = randi() % 6
	$Timer.start()
	if has_node("Path"):
		for point in $Path.get_children():
			path.append(position + point.position)

	target_idx = 0
	get_target()

func get_target():
	if path.size() > 0:
		target = path[target_idx]

func next_target():
	if path.size() > 0:
		target_idx = (target_idx + 1) % path.size()
		get_target()

func _physics_process(delta):
	if dead or !walking:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if target:
		if abs(target.x - position.x) < 10:
			next_target()

		if target.x > position.x:
			direction = Vector2.RIGHT
			if anim.current_animation != "WalkRight":
				anim.play("WalkRight")

		if target.x < position.x:
			direction = Vector2.LEFT
			if anim.current_animation != "WalkLeft":
				anim.play("WalkLeft")

		velocity = Vector2((direction * SPEED * delta).x, velocity.y)
	move_and_slide()

func hit():

	if dead:
		return

	$Sfx/Hit.play()
	$Timer.stop()
	anim.play("Die")
	walking = false
	collision_layer = 0
	collision_mask = 0
	$Timer.stop()
	dead = true
	$Hitbox.queue_free()
	$BloodSplash.emitting = true

func _on_hitbox_area_entered(area):
	if area.is_in_group("Weapon"):
		print("AREA ENTERED")
		print('ATTACKING: ' + str(area.attacking))
		print(area.name)
	if area.is_in_group("Weapon") and (area.attacking or (area.swinged and area.in_air)):
		area.hit()
		hit()

func _on_hitbox_body_entered(body):
	next_target()


func _on_interest_area_body_entered(body):
	if body.is_in_group("PhotoTarget"):
		print("Oooo!")


func _on_timer_timeout():
	walking = false
	anim.play("Shot")
	$Timer.wait_time = randi() % 6 + 1
	$Timer.start()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Shot":
		walking = true
