extends Area2D

signal level_completed

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("level_completed")
