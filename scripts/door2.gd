extends Node2D

@export var door_color: Color = Color.YELLOW
@export var slide_distance := 96.0
@export var slide_time := 0.4
@export var slide_up := true

@onready var body_to_move := $StaticBody2D # We move the collision + sprite
@onready var sprite := $Sprite2D

var _closed_y: float
var _open_y: float
var _tween: Tween
var is_unlocked: bool = false

func _ready() -> void:
	sprite.modulate = door_color
	# We use local position for easier math
	_closed_y = body_to_move.position.y
	_open_y = _closed_y + (-slide_distance if slide_up else slide_distance)
	
	if has_node("DetectionArea"):
		$DetectionArea.body_entered.connect(_on_detection_area_entered)

func _on_detection_area_entered(body: Node2D) -> void:
	print(body)
	if is_unlocked: return
	
	if "collected_keys" in body:
		for i in range(body.collected_keys.size()):
			if body.collected_keys[i].is_equal_approx(door_color):
				is_unlocked = true
				body.collected_keys.remove_at(i)
				open()
				break

func open():
	_move_to(_open_y)
	# Disable the physics wall so the player can pass
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)

func close():
	if not is_unlocked:
		_move_to(_closed_y)
		$StaticBody2D/CollisionShape2D.set_deferred("disabled", false)

func _move_to(target_y: float):
	if _tween:
		_tween.kill()

	_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Move both the sprite and the collision wall
	_tween.tween_property(body_to_move, "position:y", target_y, slide_time)
	_tween.tween_property(sprite, "position:y", target_y, slide_time)
