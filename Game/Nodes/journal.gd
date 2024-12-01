extends Control

var is_open = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/MarginContainer.visible = false

func open():
	is_open = true
	$AnimationPlayer.play("open")

func close():
	is_open = false
	$AnimationPlayer.play_backwards("open")



func _on_suf_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print_debug(str(is_open))
	$CanvasLayer/MarginContainer/TextureRect/Suf/Sprite2D.self_modulate.a = 0.9
	if event.is_action_pressed("Tool"):
		print_debug("you clicked suf")
		$CanvasLayer/MarginContainer/TextureRect/Suf/Sprite2D.self_modulate.a = 0.7
		

func _on_suf_mouse_exited() -> void:
	$CanvasLayer/MarginContainer/TextureRect/Suf/Sprite2D.self_modulate.a = 1
