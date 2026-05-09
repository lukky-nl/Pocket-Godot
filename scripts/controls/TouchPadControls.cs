using System;
using Godot;

public partial class TouchPadControls : Control
{
	private TextureRect _baseRect;
	private TextureRect _handleRect;
	
	private float _joystickScale = 0.33f;
	// In order to support multitouch we need to keep track the index or ID of the fingers on screen
	private int? _joystickFingerIndex = null;
	private int? _touchPadFingerIndex = null;
	private float _joystickStartingSize;
	private float _joystickHandleStartingSize;

	// This vector keeps track of the last position on the touch pad
	// The difference between the last position and the current position on the touchpad is our touch pad output
	private Vector2 _touchPadLastPosition = Vector2.Zero;

	// Final joystick output after normalization ( Use get_joystick() to read out this value ) 
	private Vector2 _joystick = Vector2.Zero;

	// Final touchpad output ( Use get_touchpad_delta() to read out this value )
	private Vector2 _touchPadDelta = Vector2.Zero;
	
	// Window size variables
	private float _windowWidth = 0; 
	private float _windowHeight = 0;	
	
	public override void _Ready()
	{
		_baseRect = GetNode<TextureRect>("base");
		_handleRect = GetNode<TextureRect>("handle");
		
		_windowWidth = GetWindow().ContentScaleSize.X;
		_windowHeight = GetWindow().ContentScaleSize.Y;
	
		// Setting joystick base and handle sizes based on screen height and joystick scale
		_joystickStartingSize = _windowHeight * _joystickScale;
		_joystickHandleStartingSize = _joystickStartingSize / 2;
		
		_baseRect.Size = new Vector2(_joystickStartingSize, _joystickStartingSize);
		_handleRect.Size = new Vector2(_joystickHandleStartingSize, _joystickHandleStartingSize);
	}

	public override void _Input(InputEvent inputEvent)
	{
		if (inputEvent is InputEventScreenTouch)
		{
			var touchEvent = (InputEventScreenTouch)inputEvent;
			if (touchEvent.IsPressed())
			{
				//checking if the touch is on the left of the screen and the joystick is not yet active
				if (touchEvent.Position.X * GetViewport().GetScreenTransform().X.X < _windowWidth / 2 && (_joystickFingerIndex == null)) {
					_baseRect.Show();
					_handleRect.Show();
					_baseRect.Position = touchEvent.Position - (_baseRect.Size / 2);
					_handleRect.Position = touchEvent.Position - (_baseRect.Size / 2) + (_handleRect.Size / 2);
					_joystickFingerIndex = touchEvent.Index;
				}
				else {
					_touchPadLastPosition = touchEvent.Position;
					_touchPadFingerIndex = touchEvent.Index;
				}
				
			} else {
				if (touchEvent.Index == _joystickFingerIndex)
				{
					_baseRect.Hide();
					_handleRect.Hide();
					_joystick = Vector2.Zero;
					_joystickFingerIndex = null;
				}

				if (touchEvent.Index == _touchPadFingerIndex)
				{
					_touchPadFingerIndex = null;
				}
			}
		}

		if (inputEvent is InputEventScreenDrag)
		{
			var dragEvent = (InputEventScreenDrag)inputEvent;
			if (dragEvent.Index == _joystickFingerIndex)
			{
				//handle touch drag of the joystick
				var handlePos = dragEvent.Position;
				var handleNormalized = dragEvent.Position;

				handlePos -= _handleRect.Size / 2;

				handleNormalized -= (_baseRect.Position + _baseRect.Size / 2);
				handleNormalized = handleNormalized / _baseRect.Size / 2;

				_joystick = handleNormalized / _baseRect.Size / 2;

				handleNormalized = handleNormalized.Normalized();

				handleNormalized = handleNormalized * _baseRect.Size / 2;
				handleNormalized += (_baseRect.Position + _baseRect.Size / 2);
				handleNormalized -= _handleRect.Size / 2;
				
				
				//if touch moves outside of the joystick base use the normalized position of the handle
				// this way the joystick handle never moues outside of the base
				if (dragEvent.Position.DistanceTo(_baseRect.Position + _baseRect.Size / 2) < _baseRect.Size.X / 2)
				{
					_handleRect.Position = handlePos;
				}
				else
				{
					_handleRect.Position = handleNormalized;
				}
				
			} 
			else if (dragEvent.Index == _touchPadFingerIndex)
			{
				var movement = dragEvent.Position - _touchPadLastPosition;
				_touchPadLastPosition = dragEvent.Position;
				_touchPadDelta += movement;

			}
		}
	}

	public Vector2 GetJoystick()
	{
		return _joystick;
	}
	
	// input function and update function may not run in sync so change in touchpad location is stored
	public Vector2 GetTouchPadDelta()
	{
		var delta = _touchPadDelta;
		_touchPadDelta = Vector2.Zero;
		return delta;
	}
	
}
