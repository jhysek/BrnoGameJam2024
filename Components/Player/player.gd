extends CharacterBody2D

@export var game: Node2D

@export var GRAVITY = 70 * 70 * 1.2
@export var SPEED   = 40000 #40000
@export var JUMP_SPEED  = -1600
@export var COYOTE_TIME = 0.14

enum State {
  READY,
  MOUNTED,
  DEAD
}

var double_jumped = false
var in_air = false
var was_in_air = false
var jump_timeout = 0
var prev_anim = "Idle"

var state = State.READY
var motion = Vector2(0,0)

@onready var anim = $AnimationPlayer
@onready var sword = $Visual/Body/ArmBack
@onready var anim_sword = $Visual/Body/ArmBack/AnimationPlayer
@onready var sfx_run = null

func _ready():
	if !game:
		assert(game)

func _physics_process(delta):
	if game and game.paused:
		return

	if state == State.MOUNTED:
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
	handle_attack()

	# TODO: will I have multiple states?
	#if state != State.READY:
 	#	if !in_air:
	#   	motion.x = 0
	#  return

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

	if sfx_run and sfx_run.playing:
		sfx_run.stop()


func handle_jumping(delta):
	var grounded = is_on_floor()

	if grounded:
		in_air = false
		double_jumped = true
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

	if (!in_air or !double_jumped) and Input.is_action_just_pressed("ui_up"):
		print("UP")
		if in_air:
			double_jumped = true
			if $Visual.scale.x == 1:
				anim.play("DoubleJump")
			else:
				anim.play("DoubleJumpLeft")
			# $Sfx/DoubleJump.play()
		else:
			in_air = true
			double_jumped = false
			anim.play("Jump")
			#$Sfx/Run.stop()
			#$Sfx/Jump.play()
		jump_timeout = 0

		motion.y = JUMP_SPEED
		#sfx_run.stop()

func handle_attack():
	if Input.is_action_just_pressed("attack"):
		$Visual/Body/ArmBack/Sword/Area2D.attack()
		anim_sword.play("Attack")

func _on_animation_player_animation_finished(anim_name):
	$Visual/Body/ArmBack/Sword/Area2D.attacking = false

func mount(mountable):
	reparent(mountable.mount_point)
	$AnimationPlayer.play("Mount")
	state = State.MOUNTED
	var tween = create_tween().parallel()
	tween.tween_property(self, 'position', mountable.mount_point.position, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property($Visual/Body, 'rotation', 0, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

