extends KinematicBody2D

var direction = Vector2.RIGHT 
var velocity = Vector2.ZERO

const WALKING_ANIMATION = "Walking"
const FACING_RIGHT = 0

onready var animatedSprite = $AnimatedSprite
onready var ledgeCheck = $LedgeCheck

func _physics_process(_delta):
	var found_wall = is_on_wall()
	var found_ledge = not ledgeCheck.is_colliding()

	if found_wall or found_ledge:
		direction *= -1
		apply_scale(Vector2(-1, 1))
		# animatedSprite.flip_h = not animatedSprite.flip_h

	velocity = direction * 25
	move_and_slide(velocity, Vector2.UP)

# Called when the node enters the scene tree for the first time.
func _ready():
	# animatedSprite.animation = WALKING_ANIMATION
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
