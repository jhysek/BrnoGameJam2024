extends CharacterBody2D

signal level_started
signal died

@export var STATIC = false
@export var game: Node2D

@export var GRAVITY = 70 * 70 * 1.2
@export var SPEED   = 40000 #40000
@export var JUMP_SPEED  = -1600
@export var COYOTE_TIME = 0.14


enum State {
  INIT,
  READY,
  MOUNTED,
  DEAD
}

var double_jumped = false
var in_air = false
var was_in_air = false
var jump_timeout = 0
var prev_anim = "Idle"


var state = State.INIT
var motion = Vector2(0,0)

@onready var anim = $AnimationPlayer
@onready var sword = $Visual/Body/ArmBack
@onready var anim_sword = $Visual/Body/ArmBack/AnimationPlayer
@onready var sfx_run = null
@onready var orig_scale = scale

func _ready():
	if !STATIC and !game:
		assert(game)

func _physics_process(delta):
	if game and game.paused:
		return

	if state == State.MOUNTED:
		return

	motion.y += GRAVITY * delta

	if !STATIC and state != State.DEAD:
		controlled_process(delta)
	else:
		motion.x = 0

	set_velocity(motion)
	move_and_slide()
	motion = get_real_velocity()

func controlled_process(delta):
	handle_jumping(delta)
	handle_walking(delta)
	handle_attack()


func handle_walking(delta):
	if Input.is_action_pressed('ui_right'):
		if state == State.INIT:
			state = State.READY
			emit_signal("level_started")

		if !in_air and anim.current_animation != "WalkRight":
			anim.play("WalkRight")
		if in_air:
			$Visual.scale.x = 1
		motion.x = min(motion.x + SPEED * delta, SPEED * delta)

		if sfx_run and !sfx_run.playing and !in_air:
			pass
			#sfx_run.play()

	if Input.is_action_pressed('ui_left'):
		if state == State.INIT:
			state = State.READY
			emit_signal("level_started")

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
		sfx_jump()

	was_in_air = in_air

	if (!in_air or !double_jumped) and Input.is_action_just_pressed("ui_up"):
		if state == State.INIT:
			state = State.READY
			emit_signal("level_started")
		print("UP")
		if in_air:
			double_jumped = true
			if $Visual.scale.x == 1:
				anim.play("DoubleJump")
			else:
				anim.play("DoubleJumpLeft")
			sfx_jump()

		else:
			in_air = true
			double_jumped = false
			anim.play("Jump")
			#$Sfx/Run.stop()
			sfx_jump()
		jump_timeout = 0
		$DustParticles.emitting = true
		motion.y = JUMP_SPEED
		#sfx_run.stop()

func handle_attack():
	if Input.is_action_just_released("attack"):
		print("RELEASE")
		$Visual/Body/ArmBack/Sword/Area2D.attack()
		anim_sword.play("AttackRelease")

	if Input.is_action_just_pressed("attack"):
		print("PRESS")
		anim_sword.play("AttackPress")


func mount(mountable):
	reparent(mountable.mount_point)
	anim.play("Mount")
	state = State.MOUNTED
	var tween = create_tween()
	tween.tween_property(self, 'position', mountable.mount_point.position, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func unmount():
	var cam = $Camera2D
	cam.reparent(get_parent())
	reparent(game)
	cam.reparent(self)
	state = State.READY
	scale = orig_scale
	in_air = true
	double_jumped = false
	anim.play("Unmount")

func die():
	emit_signal("died")

func sfx_jump():
	var i = randi() % 4 + 1
	get_node("Sfx/Jump" + str(i)).play()
