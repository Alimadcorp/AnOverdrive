extends Node2D

@onready var levels := $Levels
@onready var fade := $CanvasLayer/Fade
@onready var player := $Player
@onready var bg = $"BG Music"
@onready var shader_rect = $"CanvasLayer/Shader"
@onready var ph = $"CanvasLayer/Healths/Left"
@onready var zh = $"CanvasLayer/Healths/Right"
var property_list = ["curvature", "scanline_density", "interlace_strength", "chroma_offset_px", "wobble_px", "jitter_px", "tape_noise"]
var player_health = 100
var zombie_health = 100
var ainv = false
var done = false

func fight_mode(en):
	$"CanvasLayer/Healths".visible = en
	player.linear_velocity = Vector2.ZERO
	player.angular_velocity = 0
	var target_pos: Vector2 = $"FightPos".global_position if en else $"BackPos".global_position
	var state = PhysicsServer2D.body_get_direct_state(player.get_rid())
	if state:
		state.transform.origin = target_pos
	if en:
		$"Levels/9/FightZombie".enabledd = true
		$FightCam.enabled = true
		$Player/Camera2D.enabled = false
		$FightCam.make_current()
	else:
		$FightCam.enabled = false
		$Player/Camera2D.enabled = true
		$Player/Camera2D.make_current()

func dmg_player(amt):
	player_health -= amt
	player_health = clamp(player_health, 0, 100)
	if(player_health == 0 and !done):
		done = true
		await emotional_damage(false)
		fight_mode(false)

func emotional_damage(win):
	$DMGAUDIO.play() 
	inv()
	await get_tree().create_timer(2.3).timeout
	if win:
		$CanvasLayer/Label2.visible = true
		$CanvasLayer/Label3.visible = true
	else:
		$CanvasLayer/Label.visible = true
	inv()
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_property($FightCam, "rotation", 100, 5.0)
	tween.tween_property($FightCam, "zoom", Vector2(0.45, 0.45), 5.0)
	await tween.finished
	$CanvasLayer/Label.visible = false
	$CanvasLayer/Label2.visible = false
	$CanvasLayer/Label3.visible = false

func inv():
	ainv = !ainv
	shader_rect.material.set_shader_parameter("invert", ainv)

func dmg_zombie(amt):
	zombie_health -= amt
	zombie_health = clamp(zombie_health, 0, 100)
	if(zombie_health == 0 and !done):
		done = true
		await emotional_damage(true)
		fight_mode(false)

func _process(delta: float) -> void:
	zh.value = lerpf(zh.value, zombie_health, 0.5)
	ph.value = lerpf(ph.value, player_health, 0.5)

func _ready() -> void:
	_setup_level(true)

func _on_finish_level_completed() -> void:
	await fade.fade_out()
	State.loop_count += 1
	_setup_level(false)
	for i in property_list:
		var lval = shader_rect.material.get_shader_parameter(i)
		shader_rect.material.set_shader_parameter(i, lval * 1.2)
	await fade.fade_in()

func _setup_level(immediate: bool) -> void:
	if not immediate: bg.pitch_scale *= 0.92
	var total_levels = levels.get_child_count()
	var level_index: int = int(State.loop_count % total_levels)
	if(int(State.loop_count) == total_levels):
		get_tree().change_scene_to_file("res://home.tscn")
	for i in range(total_levels):
		var level = levels.get_child(i)
		_set_level_active(level, i == level_index)
	var spawn = $PlayerSpawn
	player.global_position = spawn.global_position

func _set_level_active(level: Node, active: bool) -> void:
	if level is Node2D:
		level.visible = active
		level.set_physics_process(active)
		level.set_process(active)
	_toggle_physics_recursive(level, active)

func _toggle_physics_recursive(node: Node, active: bool) -> void:
	if node is CollisionShape2D or node is CollisionPolygon2D:
		node.set_deferred("disabled", not active)
	if node is RigidBody2D:
		node.freeze = not active
		node.visible = active
	for child in node.get_children():
		_toggle_physics_recursive(child, active)
