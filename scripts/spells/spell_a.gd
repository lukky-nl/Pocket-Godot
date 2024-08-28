extends Node3D

var lifetime = 5

func _process(delta):
	
	translate(Vector3.FORWARD*delta*25)
	
	lifetime -= delta
	if lifetime < 0.0:
		queue_free()
