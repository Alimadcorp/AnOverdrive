extends RigidBody2D

@export var torque_power := 110000.0
@export var max_angular_velocity := 24.0
@export var jump_force := 800.0
@export var help_force := 400.0

# --- Audio Exports ---
@export var collision_sounds: Array[AudioStream] = []
@export var jump_sound: AudioStream
@export var collect_sound: AudioStream

@onready var collision_player := $CollisionPlayer
@onready var action_player := $ActionPlayer
@onready var torque_player := $TorquePlayer

var collected_keys: Array[Color] = []

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 5
	body_entered.connect(_on_body_entered)

func add_key(color: Color) -> void:
	collected_keys.append(color)
	action_player.stream = collect_sound
	action_player.play()

func _physics_process(_delta):
	handle_spin()
	handle_jump()
	clamp_spin()

func handle_spin():
	var input_dir = Input.get_axis("left", "right")

	if input_dir != 0:
		apply_torque(input_dir * torque_power)
		apply_force(Vector2(input_dir * help_force, 0))
		
		# Torque Sound Logic
		if not torque_player.playing:
			torque_player.play()
	else:
		# Stop sound when no input
		if torque_player.playing:
			torque_player.stop()

func handle_jump():
	if Input.is_action_just_pressed("jump"):
		apply_impulse(Vector2(0, -jump_force))
		# Jump Sound
		action_player.stream = jump_sound
		action_player.play()

func _on_body_entered(_body: Node) -> void:
	if collision_sounds.size() > 0:
		# Pick one of the 5 sounds randomly
		var random_index = randi() % collision_sounds.size()
		collision_player.stream = collision_sounds[random_index]
		collision_player.play()

func clamp_spin():
	angular_velocity = clamp(angular_velocity, -max_angular_velocity, max_angular_velocity)
