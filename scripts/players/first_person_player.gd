extends CharacterBody3D

@onready var head = $head

@export var joystick_touch_pad:Control

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const LOOKS_SENS = 2.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var movement_input_vector = Vector2.ZERO

var jump_just_pressed = false

func look(look_vector):
	
	look_vector = look_vector/get_viewport().content_scale_size.y
	look_vector = look_vector*LOOKS_SENS
	
	rotate_y(look_vector.x)
	head.rotate_x(look_vector.y)
	head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))

func _physics_process(delta):
	
	look(-joystick_touch_pad.get_touchpad_delta())
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if jump_just_pressed and is_on_floor():
		jump_just_pressed = false
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = joystick_touch_pad.get_joystick()
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func on_jump_button_pressed():
	jump_just_pressed = true
