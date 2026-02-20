extends RigidBody2D

@export var torque_power := 110000.0
@export var max_angular_velocity := 24.0

@export var ground_force := 1400.0
@export var air_force := 200.0

@export var jump_impulse := 9000.0

@onready var ray := $GroundRay


func _physics_process(delta):
	handle_spin()
	handle_jump()
	clamp_spin()


func handle_spin():
	var input_dir = Input.get_axis("left", "right")

	if input_dir != 0:
		apply_torque(input_dir * torque_power)

	# Small directional assist so it doesn't feel like ice
	var force = ground_force if is_on_floor() else air_force
	apply_force(Vector2(input_dir * force, 0))


func handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		apply_impulse(Vector2.ZERO, Vector2(0, -jump_impulse))


func clamp_spin():
	angular_velocity = clamp(
		angular_velocity,
		-max_angular_velocity,
		max_angular_velocity
	)


func is_on_floor() -> bool:
	return true
	# return ray.is_colliding()
