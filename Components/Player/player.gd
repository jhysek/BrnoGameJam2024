extends CharacterBody2D

@export var game: Node2D;

@export var GRAVITY = 70 * 70 * 1.2
@export var SPEED   = 60000 #40000
@export var JUMP_SPEED  = -1600
@export var COYOTE_TIME = 0.11

enum State {
  READY,
  DEAD
}

var double_jumped = false
var in_air = false
var was_in_air = false
var jump_timeout = 0

var state = State.READY
var motion = Vector2(0,0)

@onready var anim = $AnimationPlayer
@onready var sfx_run = null

func _ready():
	if !game:
		assert(game)

func _physics_process(delta):
	if game and game.paused:
		return

	motion.y += GRAVITY * delta

	if state != State.DEAD:
		controlled_process(delta)
	else:
		motion.x = lerp(motion.x, 0, 4 * delta)

	set_velocity(motion)
	move_and_slide()
	motion = get_real_velocity()

func controlled_process(delta):
	handle_jumping(delta)
	handle_walking(delta)

	# TODO: will I have multiple states?
	#if state != State.READY:
 	#	if !in_air:
	#   	motion.x = 0
	#  return

func handle_walking(delta):
	if Input.is_action_pressed('ui_right'):
		if !in_air and anim.current_animation != "WalkRight":
			anim.play("WalkRight")

		$Visual.scale.x = 1
		motion.x = min(motion.x + SPEED * delta, SPEED * delta)

		if sfx_run and !sfx_run.playing and !in_air:
			pass
			#sfx_run.play()

	if Input.is_action_pressed('ui_left'):
		if not in_air and anim.current_animation != "WalkLeft":
			anim.play("WalkLeft")
		$Visual.scale.x = -1
		motion.x = max(motion.x - SPEED * delta, -SPEED * delta)
		if sfx_run and !sfx_run.playing and !in_air:
			pass
			#sfx_run.play()

	elif !Input.is_action_pressed('ui_right'):
		if !in_air and anim.current_animation != "Idle":
			anim.play("Idle")
		motion.x = 0

	if sfx_run and sfx_run.playing:
		sfx_run.stop()


func handle_jumping(delta):
	var grounded = is_on_floor()

	if grounded:
		in_air = false
		double_jumped = false
		jump_timeout = 0
	elif !in_air and jump_timeout <= 0:
		jump_timeout = COYOTE_TIME

	if jump_timeout > 0:
		jump_timeout -= delta
		if jump_timeout <= 0:
			in_air = true

	if was_in_air and !in_air:
		pass
		#$Sfx/Jump.play()

	was_in_air = in_air

	print("IN AIR: " + str(in_air))
	print("DOUBLE JUMPED: " + str(double_jumped))

	if (!in_air or !double_jumped) and Input.is_action_just_pressed("ui_up"):
		print("UP")
		if in_air:
			double_jumped = true
			# anim.play("DoubleJump")
			# $Sfx/DoubleJump.play()
		else:
			in_air = true
			#anim.play("Jump")
			#$Sfx/Run.stop()
			#$Sfx/Jump.play()
		jump_timeout = 0

		print("MOTION SETTING TO UP SPEED")
		motion.y = JUMP_SPEED
		#sfx_run.stop()
