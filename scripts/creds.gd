extends Control

@onready var container = $CreditsContainer
@export var display_times: Array[float] = [3.5, 4.6, 3.8, 3.9, 5]
@export var stagger_delay := 0.6
@onready var shader_mat := $ColorRect
var shadr

func start_credits():
	var children = container.get_children()
	for i in range(0, children.size(), 2):
		for child in children:
			child.modulate.a = 0.0
			child.visible = false 
		var even_text = children[i]
		var odd_text = children[i+1] if i + 1 < children.size() else null
		even_text.visible = true
		if odd_text: odd_text.visible = true
		var pair_index = i / 2
		var current_wait = display_times[pair_index] if pair_index < display_times.size() else 1.0
		var tween = create_tween().set_parallel(true)
		tween.tween_property(even_text, "modulate:a", 1.0, 0.5)
		if odd_text:
			tween.tween_property(odd_text, "modulate:a", 1.0, 0.5).set_delay(stagger_delay)
		await get_tree().create_timer(current_wait + stagger_delay).timeout
	$CreditsContainer.visible = false
	$Menu.visible = true

func _ready() -> void:
	start_credits()
	shadr = shader_mat.material

var property_list = ["curvature", "scanline_density", "interlace_strength", "chroma_offset_px", "wobble_px", "jitter_px", "tape_noise"]

func _on_play_pressed() -> void:
	await $Fade.fade_in()
	State.loop_count = 1
	get_tree().change_scene_to_file("res://main.tscn")

func _on_exit_pressed() -> void:
	for i in property_list:
		var lval = shadr.get_shader_parameter(i)
		shadr.set_shader_parameter(i, lval * 6)
	shadr.set_shader_parameter("invert", true)
	State.loop_count = 0
	await get_tree().create_timer(1).timeout
	await $Fade.fade_in()
	get_tree().change_scene_to_file("res://main.tscn")
