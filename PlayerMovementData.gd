extends Resource
class_name PlayerMovementData

# How high the character can jump. (-inf, 0) brings you up.
export(int) var JUMP_FORCE = -160
# TODO insert description
export(int) var JUMP_RELEASE_FORCE = -40
# TODO insert description
export(int) var JUMP_RELEASE_HEIGHT = -70
# TODO insert description
export(int) var GRAVITY = 5
# TODO insert description
export(int) var GRAVITY_LIMIT = 200
# TODO insert description
export(int) var GRAVITY_MODIFIER = 2
# TODO insert description
export(int) var MAX_SPEED = 75
# TODO insert description
export(int) var FRICTION = 10
# TODO insert description
export(int) var ACCELERATION = 20
# TODO insert description
export(int) var STILL = 0
# Climb speed.
export(int) var CLIMB_SPEED = 50
# Jump buffer (leniency) timer in seconds.
export(float) var JUMP_BUFFER = 0.1
# Coyote jump timer buffer in seconds.
export(float) var COYOTE_JUMP = 0.3