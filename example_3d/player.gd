extends CharacterBody3D

@export var camera_3d: Camera3D

const SPEED = 12.0
const JUMP_VELOCITY = 7
const MOUSE_SENSITIVITY = 0.005
const MIN_X_ANGLE_DEGREE: float = -100
const MAX_X_ANGLE_DEGREE: float = 100

	
func _physics_process(delta: float) -> void:
	if global_position.y < -60:
		global_position = Vector3 (0, 10, 0)

	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if !direction.is_zero_approx():
		velocity.x =direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if not is_on_floor(): #gravity
		velocity += Vector3(20, -15, 0) * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var iemm: InputEventMouseMotion = event as InputEventMouseMotion
		rotate_y(-iemm.relative.x * MOUSE_SENSITIVITY)
		camera_3d.rotate_x(-iemm.relative.y * MOUSE_SENSITIVITY)
		camera_3d.rotation.x = clampf(camera_3d.rotation.x, deg_to_rad(MIN_X_ANGLE_DEGREE), deg_to_rad(MAX_X_ANGLE_DEGREE))
	
