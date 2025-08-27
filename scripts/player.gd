extends CharacterBody2D

const SPEED = 140.0
const ACCELERATION = 750.0
const FRICTION = 800.0

const JUMP_VELOCITY = -300.0
const FALL_MULTIPLIER = 1.6
const LOW_JUMP_MULTIPLIER = 2.0
const COYOTE_TIME = 0.15
const JUMP_BUFFER_TIME = 0.15

const WALL_SLIDE_SPEED = 50.0     
const WALL_JUMP_FORCE = 120.0     
const WALL_JUMP_TIME = 0.1        #movement block after wall jump

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var wall_jump_timer: float = 0.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var jump_sound = $JumpSound

func _physics_process(delta: float) -> void:
	# === Timer ===
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta

	if wall_jump_timer > 0:
		wall_jump_timer -= delta

	# === Gravity ===
	if not is_on_floor():
		if velocity.y > 0: #Falling
			velocity.y += gravity * (FALL_MULTIPLIER - 1) * delta
		elif velocity.y < 0 and not Input.is_action_pressed("jump"): #Short jump
			velocity.y += gravity * (LOW_JUMP_MULTIPLIER - 1) * delta

		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# === Wall Slide ===
	var on_wall_left = is_on_wall() and get_wall_normal().x > 0
	var on_wall_right = is_on_wall() and get_wall_normal().x < 0
	var wall_sliding = false

	if not is_on_floor() and (on_wall_left or on_wall_right) and Input.get_axis("move_left", "move_right") != 0:
		if velocity.y > WALL_SLIDE_SPEED:
			velocity.y = WALL_SLIDE_SPEED
		wall_sliding = true

	# === Jump ===
	if jump_buffer_timer > 0:
		if coyote_timer > 0: #Normal Jump
			velocity.y = JUMP_VELOCITY
			jump_sound.play()
			jump_buffer_timer = 0
			coyote_timer = 0
		elif wall_sliding: #Jump from wall
			velocity.y = JUMP_VELOCITY
			if on_wall_left:
				velocity.x = WALL_JUMP_FORCE
			elif on_wall_right:
				velocity.x = -WALL_JUMP_FORCE
			jump_sound.play()
			jump_buffer_timer = 0
			wall_jump_timer = WALL_JUMP_TIME

	# === Movement by X ===
	var direction := Input.get_axis("move_left", "move_right")

	if wall_jump_timer <= 0: # блокируем управление, пока идёт wall jump
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# === Sprite and animations ===
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	elif wall_sliding:
		animated_sprite.play("slide")
	else:
		animated_sprite.play("jump")

	# === Moving player ===
	move_and_slide()
