extends Node3D

var lifetime = 5

func _process(delta):
	scale += Vector3.ONE * delta * 8
	position.y -= delta * 2
	
	lifetime -= delta
	if lifetime < 0.0:
		queue_free()
