extends Node2D

func _on_finish_level_completed() -> void:
	await $CanvasLayer/Fade.fade_out()
	State.loop_count += 1
	var level = $Level
	level.queue_free()
	var new_level = preload("res://main.tscn").instantiate()
	add_child(new_level)
	$Player.global_position = new_level.get_node("PlayerSpawn").global_position
	await $CanvasLayer/Fade.fade_in()
