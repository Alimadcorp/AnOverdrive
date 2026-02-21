extends RigidBody2D

@export var torque_power := 150000.0
@export var help_force := 600.0
@export var max_angular_velocity := 30.0
@export var jump_force := 700.0
var enabledd = false
var player: RigidBody2D
var main: Node2D

func _ready() -> void:
	main = get_parent().get_parent().get_parent()
	player = main.find_child("Player")
	contact_monitor = true
	max_contacts_reported = 5

func _physics_process(_delta: float) -> void:
	if enabledd:
		move_towards_player()
		random_twitch()
		clamp_spin()

func move_towards_player():
	var dir = sign(player.global_position.x - global_position.x)
	apply_torque(dir * torque_power)
	apply_force(Vector2(dir * help_force, 0))

func random_twitch():
	if randf() < 0.005:
		var jump_vec = Vector2(randf_range(-200, 200), -jump_force)
		apply_impulse(jump_vec)

func clamp_spin():
	angular_velocity = clamp(angular_velocity, -max_angular_velocity, max_angular_velocity)
