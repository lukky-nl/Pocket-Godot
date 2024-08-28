extends Node3D

var time:float = 0

func _process(delta):
	time += delta*2
	position.y = ((sin(time)+1)/8)+0.5
	rotate_y(delta/2)
