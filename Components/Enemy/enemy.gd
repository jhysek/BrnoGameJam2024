extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var path = []
var target_idx = 0
var target
var direction = Vector2.LEFT

const SPEED = 10000

@onready var anim = $AnimationPlayer

func _ready():
	for point in $Path.get_children():
		path.append(position + point.position)

	target_idx = 0
	get_target()

func get_target():
	target = path[target_idx]

func next_target():
	target_idx = (target_idx + 1) % path.size()
	get_target()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if target:
		print("-> " + str(target))
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
	var splash = $BloodSplash
	if !splash:
		return
	splash.reparent(get_parent())
	splash.emitting = true
	queue_free()

func _on_hitbox_area_entered(area):
	if area.is_in_group("Weapon") and area.attacking:
		hit()


func _on_hitbox_body_entered(body):
	print("HIT")
	next_target()


func _on_interest_area_body_entered(body):
	if body.is_in_group("PhotoTarget"):
		print("Oooo!")