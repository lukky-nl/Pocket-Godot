extends CharacterBody3D

@export var joystick_touch_pad:Control

@onready var player_model = $player_model

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const LOOKS_SENS = 2.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var movement_input_vector = Vector2.ZERO

var jump_just_pressed = false

var spell_a = preload("res://scenes/demos/top_down_spells/spell_a.tscn")
var spell_b = preload("res://scenes/demos/top_down_spells/spell_b.tscn")

func _physics_process(delta):
	
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
	
	if input_dir != Vector2.ZERO:
		player_model.rotation.y = -input_dir.angle()
		
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


func _on_action_a_button_pressed():
	var new_spell_a = spell_a.instantiate()
	new_spell_a.rotation.y = player_model.rotation.y - deg_to_rad(45)
	new_spell_a.position = position + Vector3.UP
	get_parent().add_child(new_spell_a)


func _on_action_b_button_pressed():
	var new_spell_b = spell_b.instantiate()
	new_spell_b.position = position
	get_parent().add_child(new_spell_b)

func _on_action_c_button_pressed():
	player_model.get_surface_override_material(0).set_albedo(Color(randf_range(0,1),randf_range(0,1),randf_range(0,1)))
