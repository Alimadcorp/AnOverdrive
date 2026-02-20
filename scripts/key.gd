extends Area2D

@export var key_color: Color = Color.YELLOW

func _ready() -> void:
	$Sprite2D.modulate = key_color
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("add_key"):
		body.add_key(key_color)
		queue_free()
