extends Control

# UI elements for the joystick
@onready var base = $base
@onready var handle = $handle

# Joystick scale is based on screen height default is 0.33 so 33% of screen height
@export_category("Based on screen height")
@export_range(0,1) var joystick_scale:float = 0.33

# Joystick finger index
# In order to support multitouch we need to keep track the index or ID of the fingers on screen
var joystick_finger_index = 0

# Joystick ui size variables these are set in the _ready function
var joystick_starting_size: float
var joystick_handle_starting_size: float

# Touch pad finger index
# In order to support multitouch we need to keep track the index or ID of the fingers on screen
var touch_pad_finger_index = 0

# This vector keeps track of the last position on the touch pad
# The diffrence between the last position and the current position on the touchpad is our touch pad output
var touch_pad_last_position: Vector2 = Vector2.ZERO

# Final joystick output after normalization ( Use get_joystick() to read out this value ) 
var joystick: Vector2 = Vector2.ZERO

# Final touchpad output ( Use get_touchpad_delta() to read out this value )
var touchpad_delta: Vector2 = Vector2.ZERO


# Window size variables
var window_width = 0
var window_height = 0

func _ready():
	# Gettings screen size
	window_width = get_viewport().content_scale_size.x
	window_height = get_viewport().content_scale_size.y
	
	# Setting joystick base and handle sizes based on screen height and joystick scale
	joystick_starting_size = window_height*joystick_scale
	joystick_handle_starting_size = joystick_starting_size/2
	
	# Setting the sizes of the ui elements of the joystick
	base.size = Vector2(joystick_starting_size,joystick_starting_size)
	handle.size = Vector2(joystick_handle_starting_size,joystick_handle_starting_size)

func _input(event):
	# Checking if input is a touch
	if event is InputEventScreenTouch:
		# Handeling the start of a touch
		if event.pressed:
			# Checking if touch is on the left of the screen and the joystick if not yet active
			if event.position.x * get_viewport().get_screen_transform().x.x < window_width/2 && !joystick_finger_index:
				# Starting the joystick touch
				base.show()
				handle.show()
				base.position =  event.position - (base.size/2)
				handle.position = event.position - (base.size/2)  + (handle.size/2)
				joystick_finger_index = event.index
			else:
				# Starting the touchpad touch
				touch_pad_last_position = event.position
				touch_pad_finger_index = event.index
		else:
			# Handeling the end of a touch
			if event.index == joystick_finger_index:
				# Ending joystick touch hiding the ui and reseting the joystick
				base.hide()
				handle.hide()
				joystick = Vector2.ZERO
				joystick_finger_index = null
			if event.index == touch_pad_finger_index:
				# Ending touchpad touch
				touch_pad_finger_index = null
	# Checking if input is a touch drag 
	if event is InputEventScreenDrag:
		if event.index == joystick_finger_index:
			# Handeling touch drag of joystick 
			var handle_pos = event.position
			var handle_normalized = event.position
			
			handle_pos -= handle.size/2
			
			handle_normalized -= (base.position + base.size/2)
			handle_normalized = handle_normalized/base.size/2
			
			joystick = handle_normalized/base.size/2
			
			handle_normalized = handle_normalized.normalized()
			
			handle_normalized = handle_normalized*base.size/2
			handle_normalized += (base.position + base.size/2)
			handle_normalized -= handle.size/2
			
			# If touch moves outside of the joystick base use the normalized position of the handle 
			# This way the joystick handle never moves outside of the base
			if event.position.distance_to(base.position+base.size/2) < base.size.x/2:
				handle.position = handle_pos
			else:
				handle.position = handle_normalized
			
		elif event.index == touch_pad_finger_index:
			# Handeling touch drag of the touchpad
			var movement = event.position - touch_pad_last_position
			touch_pad_last_position = event.position
			touchpad_delta += movement

# Getter for joystick value
func get_joystick() -> Vector2:
	return joystick

# Getter for touchpad value 
# IMPORTANT : always use the get_touchpad_delta function to get the touchpad value
# input function and update funtion may not run in sinc so change in touchpad location is stored until
# get function is called making sure no touchpad data is lost 
func get_touchpad_delta() -> Vector2:
	var touchpad_delta_return = touchpad_delta
	touchpad_delta = Vector2.ZERO
	return touchpad_delta_return
