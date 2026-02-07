extends RigidBody2D

@onready var arrow = $Arrow
@export var force := 600.0

func _physics_process(_delta):
	var mouse := get_global_mouse_position()
	var world_angle := (mouse - global_position).angle()
	arrow.rotation = world_angle - global_rotation

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var mouse := get_global_mouse_position()
		var world_angle := (mouse - global_position).angle()
		arrow.rotation = world_angle - global_rotation
		var forward := Vector2.RIGHT.rotated(arrow.global_rotation)
		apply_impulse(forward * force)
