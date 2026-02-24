extends Area3D

@export var plattform1: RigidBody3D
@export var plattform2: RigidBody3D

var tween: Tween = null

func _on_body_entered(_body: Node3D) -> void:
	print("on body entered: ", _body)
	if is_instance_valid(tween):
		tween.kill()
	plattform2.gravity_scale = 0.0
	plattform2.angular_velocity = Vector3.ZERO
	plattform2.linear_velocity = Vector3.ZERO
	
	tween = create_tween()
	tween.tween_property(plattform1, "global_position:y", 5.0, 0.3)
	tween.tween_property(plattform2, "global_position:y", 5.0, 0.3)
	
func _on_body_exited(_body: Node3D) -> void:
	plattform2.gravity_scale = 1.0
	
