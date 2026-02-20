extends CharacterBody2D

@export var gravity := 3000.0
@export var move_speed := 900.0
@export var acceleration := 3000.0
@export var friction := 1200.0
@export var jump_force := 1200.0

@export var coyote_time := 0.12
@export var jump_buffer_time := 0.12

@export var dash_speed := 1500.0
@export var dash_time := 0.15
@export var dash_cooldown := 0.4

var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0

var _is_dashing := false
var _dash_timer := 0.0
var _dash_cd_timer := 0.0
var _dash_dir := 0.0


func _physics_process(delta: float) -> void:
	handle_timers(delta)
	handle_gravity(delta)
	handle_jump()
	handle_dash(delta)
	handle_movement(delta)
	move_and_slide()


func handle_timers(delta):
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer -= delta

	_jump_buffer_timer -= delta
	_dash_cd_timer -= delta


func handle_gravity(delta):
	if not is_on_floor() and not _is_dashing:
		velocity.y += gravity * delta


func handle_jump():
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time

	if _jump_buffer_timer > 0 and _coyote_timer > 0:
		velocity.y = -jump_force
		_jump_buffer_timer = 0
		_coyote_timer = 0


func handle_dash(delta):
	if _is_dashing:
		_dash_timer -= delta
		velocity.x = _dash_dir * dash_speed
		velocity.y = 0
		if _dash_timer <= 0:
			_is_dashing = false
		return

	if Input.is_action_just_pressed("dash") and _dash_cd_timer <= 0:
		_is_dashing = true
		_dash_timer = dash_time
		_dash_cd_timer = dash_cooldown
		_dash_dir = sign(Input.get_axis("left", "right"))
		if _dash_dir == 0:
			_dash_dir = sign(scale.x)


func handle_movement(delta):
	if _is_dashing:
		return

	var input_dir = Input.get_axis("left", "right")

	if input_dir != 0:
		velocity.x = move_toward(
			velocity.x,
			input_dir * move_speed,
			acceleration * delta
		)
		scale.x = sign(input_dir)
	else:
		velocity.x = move_toward(
			velocity.x,
			0,
			friction * delta
		)
