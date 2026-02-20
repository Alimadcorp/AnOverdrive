extends RigidBody2D

@export var torque_power := 110000.0
@export var max_angular_velocity := 24.0

@export var jump_force := 800.0
@export var help_force := 400.0

@export var jump_impulse := 9000.0

@onready var ray := $GroundRay

var collected_keys: Array[Color] = []

func add_key(color: Color) -> void:
	collected_keys.append(color)

func _physics_process(delta):
	handle_spin()
	handle_jump()
	clamp_spin()


func handle_spin():
	var input_dir = Input.get_axis("left", "right")

	if input_dir != 0:
		apply_torque(input_dir * torque_power)
		apply_force(Vector2(input_dir * help_force, 0))

func handle_jump():
	if Input.is_action_just_pressed("jump"):
		apply_impulse(Vector2(0, -jump_force))


func clamp_spin():
	angular_velocity = clamp(
		angular_velocity,
		-max_angular_velocity,
		max_angular_velocity
	)


func is_on_floor() -> bool:
	return true
	# return ray.is_colliding()
