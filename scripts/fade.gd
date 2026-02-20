extends ColorRect

func fade_out():
	var t = create_tween()
	t.tween_property(self, "modulate:a", 1.0, 0.5)
	await t.finished

func fade_in():
	var t = create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.5)
