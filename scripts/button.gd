extends StaticBody2D

@export var linked_door: NodePath

@onready var area := $DetectionArea
@onready var sprite := $Sprite2D
@onready var door := get_node_or_null(linked_door)

var bodies := []


func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	update_state()

func _on_body_entered(body):
	if body is RigidBody2D:
		bodies.append(body)
		update_state()

func _on_body_exited(body):
	if body in bodies:
		bodies.erase(body)
		update_state()


func update_state():
	var pressed = bodies.size() > 0

	sprite.modulate = Color(1.4,0.4,0.4) if pressed else Color(1,0,0)

	if door:
		if pressed:
			door.open()
		else:
			door.close()
