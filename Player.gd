extends KinematicBody2D
class_name Player

# State machine enum.
# TODO have better FSM. https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/
enum {
	MOVE,
	CLIMB,
}

export(Resource) var moveData = preload("res://FastPlayerMovementData.tres") as PlayerMovementData

const RUN_ANIMATION = "Run"
const IDLE_ANIMATION = "Idle"
const JUMP_ANIMATION = "Jump"
const GREEN_SKIN = "res://PlayerGreenSkin.tres"
const PINK_SKIN = "res://PlayerPinkSkin.tres"
const RUN_FRAME = 1

var velocity = Vector2.ZERO
var double_jump = false
var state = MOVE
var buffered_jump = false
var coyote_jump = false

onready var animatedSprite: = $AnimatedSprite
onready var ladderCheck: = $LadderCheck
onready var jumpBufferTimer: = $JumpBufferTimer
onready var coyoteJumpTimer: = $CoyoteJumpTimer

# Action handles.
func apply_gravity():
	velocity.y += moveData.GRAVITY
	velocity.y = min(velocity.y, moveData.GRAVITY_LIMIT)

func apply_friction(input):
	if input.x == moveData.STILL:
		velocity.x = move_toward(velocity.x, moveData.STILL, moveData.FRICTION)
		animatedSprite.animation = IDLE_ANIMATION
	else:
		apply_acceleration(input.x)
		animatedSprite.animation = RUN_ANIMATION

func apply_acceleration(amount):
	animatedSprite.flip_h = amount > moveData.STILL
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.ACCELERATION)

func is_on_ladder():
	if not ladderCheck.is_colliding():
		return false 
	return ladderCheck.get_collider() is Ladder

func can_jump():
	return is_on_floor() or coyote_jump

func handle_jump():
	if Input.is_action_just_pressed("ui_up") or buffered_jump:
		double_jump = false
		velocity.y = moveData.JUMP_FORCE
		buffered_jump = false
		coyote_jump = false

func handle_double_jump():
	if Input.is_action_just_pressed("ui_up") and not double_jump:
		print("double jumped")
		velocity.y = moveData.JUMP_FORCE
		double_jump = true

func handle_short_jump():
	if Input.is_action_just_released("ui_up") and velocity.y < moveData.JUMP_RELEASE_HEIGHT:
		velocity.y = moveData.JUMP_RELEASE_FORCE

func handle_buffer_jump():
	if Input.is_action_just_pressed("ui_up"):
		buffered_jump = true 
		jumpBufferTimer.start()

func handle_coyote_jump(was_on_floor):
	if not is_on_floor() and was_on_floor and velocity.y > moveData.STILL:
		coyote_jump = true 
		coyoteJumpTimer.start()

func handle_landing(was_on_floor):
	if not was_on_floor and is_on_floor():
		animatedSprite.animation = RUN_ANIMATION
		animatedSprite.frame = RUN_FRAME

func handle_climbing(input):
	if input.length() != moveData.STILL:
		animatedSprite.animation = RUN_ANIMATION
	else:
		animatedSprite.animation = IDLE_ANIMATION
	velocity = input * moveData.CLIMB_SPEED
	velocity = move_and_slide(velocity, Vector2.UP)

# State functions.
func transition_climb_state():
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
		state = CLIMB

func transition_move_state():
	state = MOVE

func move_state(input: Vector2):
	if is_on_ladder():
		transition_climb_state()

	apply_gravity()
	apply_friction(input)

	if can_jump():
		handle_jump()
	else:
		animatedSprite.animation = JUMP_ANIMATION
		handle_double_jump()
		handle_short_jump()
		handle_buffer_jump()

	var was_on_floor = is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)

	handle_landing(was_on_floor)
	handle_coyote_jump(was_on_floor)

func climb_state(input: Vector2):
	if not is_on_ladder():
		transition_move_state()
	handle_climbing(input)

# Godot functions.
func _ready():
	animatedSprite.frames = load(GREEN_SKIN)
	jumpBufferTimer.one_shot = true
	jumpBufferTimer.wait_time = moveData.JUMP_BUFFER
	coyoteJumpTimer.one_shot = true 
	coyoteJumpTimer.wait_time = moveData.COYOTE_JUMP

func _on_JumpBufferTimer_timeout():
	buffered_jump = false

func _on_CoyoteJumpTimer_timeout():
	coyote_jump = false

func _physics_process(_delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	match state:
		MOVE: move_state(input)
		CLIMB: climb_state(input)

