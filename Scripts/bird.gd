extends Area2D

func _physics_process(delta):
	position.x -= (get_parent().speed / 2.0) * 60.0 * delta
