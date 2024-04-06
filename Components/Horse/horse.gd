extends CharacterBody2D

@export var GRAVITY = 70 * 70 * 1.2
@export var SPEED   = 70000
@export var JUMP_SPEED  = -1600
@export var COYOTE_TIME = 0.14

@export var game: Node2D;
@onready var anim = $AnimationPlayer
@onready var mount_point = $Visual/Body/MountPoint

enum State {
  READY,
  MOUNTED,
  DEAD
}

var state = State.READY
var motion = Vector2(0,0)
var in_air = false
var was_in_air = false
var sfx_run = null

func _ready():
	if !game:
		assert(game)


func _physics_process(delta):
	if game and game.paused:
		return

	motion.y += GRAVITY * delta

	if state == State.MOUNTED:
		controlled_process(delta)
	else:
		motion.x = lerp(motion.x, 0.0, 4 * delta)

	set_velocity(motion)
	move_and_slide()
	motion = get_real_velocity()

func controlled_process(delta):
	handle_walking(delta)
	handle_attack()

func handle_walking(delta):
	if Input.is_action_pressed('ui_right'):
		if !in_air and anim.current_animation != "WalkRight":
			anim.play("WalkRight")
		if in_air:
			$Visual.scale.x = 1
		motion.x = min(motion.x + SPEED * delta, SPEED * delta)

		if sfx_run and !sfx_run.playing and !in_air:
			pass
			#sfx_run.play()

	if Input.is_action_pressed('ui_left'):
		if not in_air and anim.current_animation != "WalkLeft":
			anim.play("WalkLeft")

		if in_air:
			$Visual.scale.x = -1
		motion.x = max(motion.x - SPEED * delta, -SPEED * delta)
		if sfx_run and !sfx_run.playing and !in_air:
			pass
			#sfx_run.play()

	elif !Input.is_action_pressed('ui_right'):
		if !in_air and anim.current_animation != "Idle":
			anim.play("Idle")
		motion.x = 0

	#if sfx_run and sfx_run.playing:
	#	sfx_run.stop()


func handle_attack():
	pass

func _on_mount_area_body_entered(body):
	if state != State.MOUNTED and body.is_in_group("Player"):
		print("MOUNT")
		anim.play("Mount")
		body.mount(self)
		state = State.MOUNTED


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Mount":
		anim.play("Idle")
