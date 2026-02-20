extends Node2D

@onready var levels := $Levels
@onready var fade := $CanvasLayer/Fade
@onready var player := $Player
@onready var bg = $"BG Music"
func _ready() -> void:
	_setup_level(true)

func _on_finish_level_completed() -> void:
	await fade.fade_out()
	State.loop_count += 1
	_setup_level(false)
	await fade.fade_in()

func _setup_level(immediate: bool) -> void:
	if not immediate: bg.pitch_scale *= 0.9
	var total_levels = levels.get_child_count()
	var level_index: int = int(State.loop_count % total_levels)
	for i in range(total_levels):
		var level = levels.get_child(i)
		_set_level_active(level, i == level_index)

	# Reset player position
	var spawn = $PlayerSpawn
	player.global_position = spawn.global_position

func _set_level_active(level: Node, active: bool) -> void:
	if level is Node2D:
		level.visible = active
		level.set_physics_process(active)
		level.set_process(active)
	
	# Fix for RigidBodies and Collisions
	_toggle_physics_recursive(level, active)

func _toggle_physics_recursive(node: Node, active: bool) -> void:
	if node is CollisionShape2D or node is CollisionPolygon2D:
		node.set_deferred("disabled", not active)
	
	# RigidBodies need to be frozen or moved to prevent them from falling 
	# through the floor of an inactive level
	if node is RigidBody2D:
		node.freeze = not active
		node.visible = active # Explicitly hide the body
		
	for child in node.get_children():
		_toggle_physics_recursive(child, active)
