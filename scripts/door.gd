extends AnimatableBody2D

@export var door_color: Color = Color.YELLOW
@export var slide_distance := 96.0
@export var slide_time := 0.4
@export var slide_up := true

var _closed_y: float
var _open_y: float
var _tween: Tween
var is_unlocked: bool = false

func _ready() -> void:
	$Sprite2D.modulate = door_color
	_closed_y = global_position.y
	_open_y = _closed_y + (-slide_distance if slide_up else slide_distance)
	if has_node("DetectionArea"):
		$DetectionArea.body_entered.connect(_on_detection_area_entered)

func _on_detection_area_entered(body: Node2D) -> void:
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

func close():
	if not is_unlocked:
		_move_to(_closed_y)

func _move_to(target_y: float):
	if _tween:
		_tween.kill()

	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "global_position:y", target_y, slide_time)
