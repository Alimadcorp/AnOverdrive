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

func fight_mode(en):
	$"CanvasLayer/Healths".visible = en
	if en:
		$FightCam.enabled = true
		$Player/Camera2D.enabled = false
		$"FightCam".make_current()
		$Player.linear_velocity = Vector2.ZERO
		$Player.angular_velocity = 0
		$"Player".global_position = $"FightPos".global_position
	else:
		$FightCam.enabled = false
		$Player/Camera2D.enabled = true
		$"Player/Camera2D".make_current()
		$Player.linear_velocity = Vector2.ZERO
		$Player.angular_velocity = 0
		$"Player".global_position = $"BackPos".global_position

func dmg_player(amt):
	player_health -= amt
	ph.value = player_health
	
func dmg_zombie(amt):
	zombie_health -= amt
	zh.value = zombie_health

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
