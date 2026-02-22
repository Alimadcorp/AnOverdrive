extends RigidBody2D

@export var torque_power := 110000.0
@export var max_angular_velocity := 24.0
@export var jump_force := 800.0
@export var help_force := 400.0

@export var collision_sounds: Array[AudioStream] = []
@export var jump_sound: AudioStream
@export var collect_sound: AudioStream

@onready var collision_player := $CollisionPlayer
@onready var action_player := $ActionPlayer
@onready var torque_player := $TorquePlayer
var main: Node2D
var _last_sound_time := 0
var _last_velocity := Vector2.ZERO
var _last_angular_velocity := 0.0
var player_radius: float = 128.0

var collected_keys: Array[Color] = []

func _ready() -> void:
	main = get_parent()
	contact_monitor = true
	max_contacts_reported = 5
	body_entered.connect(_on_body_entered)

func add_key(color: Color) -> void:
	collected_keys.append(color)
	action_player.stream = collect_sound
	action_player.play()
var restarting = false
func _physics_process(_delta):
	handle_spin()
	handle_jump()
	clamp_spin()
	_last_velocity = linear_velocity
	_last_angular_velocity = angular_velocity
	if Input.is_action_just_pressed("reset") and !restarting:
		restarting = true
		main._on_restart()

func handle_spin():
	var input_dir = Input.get_axis("left", "right")

	if input_dir != 0:
		apply_torque(input_dir * torque_power)
		apply_force(Vector2(input_dir * help_force, 0))
		if not torque_player.playing:
			torque_player.play()
	else:
		if torque_player.playing:
			torque_player.stop()

func handle_jump():
	if Input.is_action_just_pressed("jump"):
		apply_impulse(Vector2(0, -jump_force))
		action_player.stream = jump_sound
		action_player.play()

func _on_body_entered(body: Node) -> void:
	if(body.name == "Zombie"):
		if not main.ph.get_parent().visible:
			body.queue_free()
			main.fight_mode(true)
	else:
		var linear_impact = _last_velocity.length()
		var tangential_impact = abs(_last_angular_velocity) * player_radius
		var total_impact = linear_impact + (tangential_impact * 0.5)
		if total_impact < 100:
			return
		_play_collision_sound(total_impact)

func _play_collision_sound(speed: float):
	var current_time = Time.get_ticks_msec()
	if current_time - _last_sound_time < 100:
		return
	_last_sound_time = current_time
	if collision_sounds.size() > 0:
		var random_index = randi() % collision_sounds.size()
		collision_player.stream = collision_sounds[random_index]
		var volume = remap(speed, 100, 2000, -25.0, 0.0)
		collision_player.volume_db = clamp(volume, -30.0, 2.0)
		collision_player.pitch_scale = randf_range(0.85, 1.15)
		collision_player.play()

func clamp_spin():
	angular_velocity = clamp(angular_velocity, -max_angular_velocity, max_angular_velocity)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "FightZombie":
		var spin_bonus = abs(angular_velocity) * 0.5 
		var total_dmg = randf_range(3, 10) + spin_bonus
		main.dmg_zombie(total_dmg)

func _on_players_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var buzzsaw_bonus = abs(angular_velocity) * 0.8
		var total_dmg = randf_range(3, 10) + buzzsaw_bonus
		main.dmg_player(total_dmg)
