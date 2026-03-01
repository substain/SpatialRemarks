extends Area3D

@export var platform1: RigidBody3D
@export var platform2: RigidBody3D

var tween: Tween = null

var current_bodies: Array[Node3D] = []

func _on_body_entered(body: Node3D) -> void:
	if !current_bodies.has(body):
		current_bodies.append(body)
		
	if is_instance_valid(tween):
		tween.kill()
	platform2.gravity_scale = 0.0
	platform2.angular_velocity = Vector3.ZERO
	platform2.linear_velocity = Vector3.ZERO
	
	tween = create_tween()
	tween.tween_property(platform1, "global_position:y", 3.5, 0.3)
	tween.tween_property(platform2, "global_position:y", 3.5, 0.3)
	
func _on_body_exited(body: Node3D) -> void:
	if current_bodies.has(body):
		current_bodies.erase(body)	

	if current_bodies.size() == 0:
		platform2.gravity_scale = 1.0
	

	
