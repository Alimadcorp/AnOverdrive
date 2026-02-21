extends Control

@onready var container = $CreditsContainer
@export var display_times: Array[float] = [1.0, 2.0, 1.0]
@export var stagger_delay := 0.3

func start_credits():
	for child in container.get_children():
		child.modulate.a = 0.0
	
	var children = container.get_children()
	for i in range(0, children.size(), 2):
		var even_text = children[i]
		var odd_text = children[i+1] if i + 1 < children.size() else null
		
		var pair_index = i / 2
		var current_wait = display_times[pair_index] if pair_index < display_times.size() else 1.0
		var tween = create_tween().set_parallel(true)
		
		tween.tween_property(even_text, "modulate:a", 1.0, 0.5)
		if odd_text:
			tween.tween_property(odd_text, "modulate:a", 1.0, 0.5).set_delay(stagger_delay)
		await get_tree().create_timer(current_wait + stagger_delay).timeout
