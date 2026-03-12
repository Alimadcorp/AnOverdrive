extends Node

var loop_count := 1
var switches_activated := {}
var current_pitch : float = 1.0
var total_msec: int = 0

func add_to_state(msec: int):
	total_msec += msec

func get_formatted_time(msec: int) -> String:
	var seconds = msec / 1000
	var remain_msec = msec % 1000
	var mins = seconds / 60
	var remain_secs = seconds % 60
	return "%02d:%02d.%03d" % [mins, remain_secs, remain_msec]
